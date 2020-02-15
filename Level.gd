extends Node2D


const LEVEL_SIZE = Vector2(30, 20)
enum {EDIT, PLAY}


var mode = EDIT
var element_map = {}


func compute_actions(next_actions):
        
    # Setup neighbourhoods.
    for y in range(1, self.LEVEL_SIZE.y-1):
        for x in range(1, self.LEVEL_SIZE.x-1):
            if self.element_map.has([x,y]):
                var element = element_map[[x,y]]
                element.set_neighbourhood(
                        self.get_element(x-1, y-1), self.get_element(x  , y-1), self.get_element(x+1, y-1), 
                        self.get_element(x-1, y  ),                             self.get_element(x+1, y  ), 
                        self.get_element(x-1, y+1), self.get_element(x  , y+1), self.get_element(x+1, y+1)
                    )
    
    # Compute actions.
    var action_map = Actions.ActionMap.new(LEVEL_SIZE)
    for action in next_actions:
        action_map.add_action(action)
    for element in $Elements.get_children():
        var actions = element.compute_actions()
        if actions:
            for action in actions:
                action_map.add_action(action)

    # Resolve conflicts.
    print('-->', action_map.actions[[13,7]])
    action_map.resolve_conflicts()
    return action_map.get_actions()
    

func apply_actions(actions):
    
    var result = []
    
    for action in actions:
        for element in action.get_elements():
            # Testing: skip if element already removed.
            if element.get_parent() == null:
                print('Skipping action on orphaned element (%s).' % [element.to_string()])
                continue
            var next_actions = element.apply_action(action)
            if next_actions:
                for next_action in next_actions:
                    result.append(next_action)
                    
    #for element in $Elements.get_children():
    #    element.apply_action('idle')
                    
    self.element_map = {}
    for element in $Elements.get_children():
        if element.is_blank():
            $Elements.remove_child(element)
            element.queue_free()
        else:
            self.element_map[[element.map_x, element.map_y]] = element
        
    return result


var next_actions = []
func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        var actions = self.compute_actions(next_actions)
        next_actions = self.apply_actions(actions)
        print('-----')
                

func clear_level():
    for e in $Elements.get_children():
        $Elements.remove_child(e)
        e.queue_free()
    for y in range(self.LEVEL_SIZE.y):
        for x in range(self.LEVEL_SIZE.x):
            self.set_element(x, y, 'steel' if x == 0 or y == 0 or x == self.LEVEL_SIZE.x-1 or y == self.LEVEL_SIZE.y-1 else 'grass')
            

func get_element(x, y):
    if self.element_map.has([x,y]):
        return self.element_map[[x,y]]
    else:
        var element = Global.ALL_ELEMENTS['blank'].instance().setup(x, y)
        self.element_map[[x,y]] = element
        $Elements.add_child(element)
        return element
    


func set_element(x, y, element_name):
    if self.element_map.has([x,y]):
        var prev = self.element_map[[x,y]]
        $Elements.remove_child(prev)
        prev.queue_free()
    var element = Global.ALL_ELEMENTS[element_name].instance().setup(x, y)
    $Elements.add_child(element)
    self.element_map[[x,y]] = element


func set_edit_mode():
    self.mode = EDIT
    #self.clear_level()
    
    
func set_play_mode():
    self.mode = PLAY
    # Remove blanks.
    for element in $Elements.get_children():
        if element.is_blank():
            self.element_map.erase([element.map_x, element.map_y])
            $Elements.remove_child(element)
            element.queue_free()


func set_element_by_pixel(element_name, position):
    var x = int(position.x/Global.TILE_SIZE)
    var y = int(position.y/Global.TILE_SIZE)
    if x >= 0 and y >= 0 and x < LEVEL_SIZE.x and y < LEVEL_SIZE.y:
        self.set_element(x, y, element_name)


func to_json_():
    var element_map_names = []
    for y in range(self.LEVEL_SIZE.y):
        var row = []
        for x in range(self.LEVEL_SIZE.x):
            row.append(self.element_map[[x,y]].get_element_name())
        element_map_names.append(row)
    return to_json({
        'element_map_names': element_map_names
       })


func from_json(json):
    var dict = parse_json(json)
    self.clear_level()
    var y = 0
    for row in dict['element_map_names']:
        var x = 0
        for name in row:
            self.set_element(x, y, name)
            x += 1
        y += 1


func load_from_file():
    var file = File.new()
    file.open('res://levels/1.json', File.READ)
    var json = file.get_line()
    file.close()
    self.from_json(json)
    

func save_to_file():
    var file = File.new()
    file.open('res://levels/1.json', File.WRITE)
    file.store_line(self.to_json_())
    file.close()
