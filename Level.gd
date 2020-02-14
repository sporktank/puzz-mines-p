extends Node2D


const LEVEL_SIZE = Vector2(30, 20)
enum {EDIT, PLAY}


var mode = EDIT
var element_map = {}


#class Neighbourhood:
#
#    var nw
#    var n
#    var ne
#    var w
#    var e
#    var sw
#    var s
#    var se
#
#    func _init(nw, n, ne, w, e, sw, s, se):
#        self.nw = nw
#        self.n = n
#        self.ne = ne
#        self.w = w
#        self.e = e
#        self.sw = sw
#        self.s = s
#        self.se = se
#
#    func to_string():
#        return str([
#                [self.nw.get_element_name(), self.n.get_element_name(), self.ne.get_element_name()],
#                [self.w.get_element_name(), '[self]', self.e.get_element_name()],
#                [self.sw.get_element_name(), self.s.get_element_name(), self.se.get_element_name()]
#            ])
#
#
#func compute_next_element_map():
#
#    # Clear actions.
#    for element in $Elements.get_children():
#        element.reset_actions()
#
#    # Compute desired actions.
#    for y in range(1, self.LEVEL_SIZE.y-1):
#        for x in range(1, self.LEVEL_SIZE.x-1):
#            var nh = Neighbourhood.new(
#                    self.element_map[[x-1, y-1]], self.element_map[[x  , y-1]], self.element_map[[x+1, y-1]], 
#                    self.element_map[[x-1, y  ]],                               self.element_map[[x+1, y  ]], 
#                    self.element_map[[x-1, y+1]], self.element_map[[x  , y+1]], self.element_map[[x+1, y+1]]
#                )
#            self.element_map[[x,y]].compute_actions(nh)
#
#    # Resolve conflicts.
#    for element in $Elements.get_children():
#        if element.possible_actions.size() > 1:
#            element.resolve_actions()
#
#    # TODO: Thinking to do this in the order order.
#    # Remove blanks.
#    for element in $Elements.get_children():
#        if element.is_blank():
#            $Elements.remove_child(element)
#            element.queue_free()
#
#    # Apply actions.
#    var new_element_map = {}
#    for element in $Elements.get_children():
#        if element.possible_actions.size() == 0:
#            new_element_map[[element.map_x, element.map_y]] = element
#        else:
#            var result = element.take_action(element.possible_actions[0])
#            if result.new_element:
#                print('Need new element!')
#            else:
#                new_element_map[[result.new_map_x, result.new_map_y]] = element.setup(result.new_map_x, result.new_map_y)
#
#    # Fill in blanks.
#    for y in range(1, self.LEVEL_SIZE.y-1):
#        for x in range(1, self.LEVEL_SIZE.x-1):
#            if not new_element_map.has([x,y]):
#                var element = Global.ALL_ELEMENTS['blank'].instance().setup(x, y)
#                new_element_map[[x,y]] = element
#                $Elements.add_child(element)
#
#    return new_element_map


func compute_actions():
    
#    # Clear actions.
#    for element in $Elements.get_children():
#        element.reset_actions()
        
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
    for element in $Elements.get_children():
        var actions = element.compute_actions()
        if actions:
            for action in actions:
                action_map.add_action(action)

#    # Resolve conflicts.
#    for element in $Elements.get_children():
#        if element.possible_actions.size() > 1:
#            element.resolve_actions()

#    for i in action_map.actions:
#        if action_map.actions[i].size() > 1:
#            #print('Conflict!')
#            #for action in action_map.actions[i]:
#            #    print(action.to_string())
#            #print('.')
#            # For testing just invalidate all but first one.
#            for action in action_map.actions[i][1:]:
#                action.invalidate()
    action_map.resolve_conflicts()
    
    return action_map.get_actions()
    

#func apply_actions():
#    var new_element_map = {}
#    for element in $Elements.get_children():
#        if element.possible_actions.size() == 0:
#            new_element_map[[element.map_x, element.map_y]] = element
#        else:
#            var result = element.apply_action(element.possible_actions[0])
#            if result.delete_element:
#                $Elements.remove_child(element)
#            elif result.new_element:
#                print('Need new element!')
#            else:
#                new_element_map[[result.new_map_x, result.new_map_y]] = element.setup(result.new_map_x, result.new_map_y)
#    self.element_map = new_element_map
func apply_actions(actions):
    for action in actions:
        for element in action.get_elements():
            var action_result = element.apply_action(action)
            if action_result and action_result.delete_me:
                $Elements.remove_child(action.element)
                action.element.queue_free()
    self.element_map = {}
    for element in $Elements.get_children():
        self.element_map[[element.map_x, element.map_y]] = element


var timer = 0.0
func _process(delta):
    timer += delta
    if Input.is_action_just_pressed("ui_accept") or timer > 0.2:
        timer = 0.0
        #self.element_map = self.compute_next_element_map()
        var actions = self.compute_actions()
        #self.animate_actions()
        self.apply_actions(actions)
                

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
        return Global.ALL_ELEMENTS['blank'].instance().setup(x, y)


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
    

#func add_element(e):
#    # TODO: Add check that not going over existing element.
#    $Elements.add_child(e)
#
#
#func load_level(level_map):
#
#    self.clear_level()
#
#    # Test data.
#    var steel = load("res://elements/Steel.tscn")
#    var grass = load("res://elements/Grass.tscn")
#    for y in range(self.LEVEL_SIZE.y):
#        for x in range(self.LEVEL_SIZE.x):
#            var e = steel.instance() if x == 0 or y == 0 or x == self.LEVEL_SIZE.x-1 or y == self.LEVEL_SIZE.y-1 else grass.instance()
#            self.add_element(e.setup(x, y))