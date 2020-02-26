extends Node2D


const LEVEL_SIZE = Vector2(30, 20)
enum {EDIT, PLAY}
#const TIMER_INTERVAL = 16#36#12
const SECONDS_PER_STEP = 0.25#0.22


var level_set
var level_number
var level_name = ''

var mode = EDIT
var element_map = {}
var actions = []
var next_actions = []
var timer = 0.0

var current_chest = 0
var chest_contents = [
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']]
    ]

# TODO: Clean this stuff up
var player_ref
var coins_required = 0
var coins_collected = 0


func restart():
    self.actions = []
    self.next_actions = []
    self.timer = 0.0
    self.coins_collected = 0
    if self.level_set and self.level_number:
        self.load_from_file(self.level_set, self.level_number)
    
    
func _ready():
    self.restart()


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
    action_map.resolve_conflicts()
    return action_map.get_actions()


func animate_actions(actions, alpha):
    for action in actions:
        for element in action.get_elements():
            element.animate_action(action, alpha)
            

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


#func _process(delta):
#    if Input.is_action_just_pressed("ui_accept"):
#        var actions = self.compute_actions(next_actions)
#        next_actions = self.apply_actions(actions)
#        print('-----')
#func _physics_process(delta):
#    if self.mode == PLAY:
#
#        #if self.timer in [0, int(TIMER_INTERVAL/2), TIMER_INTERVAL-1]:
#        #    print(self.timer)
#
#        if self.timer == 0:
#            self.actions = self.compute_actions(self.next_actions)
#            self.timer += 1  # Get off first frame of animation to make it look smooth.
#
#        if self.timer >= 0 and self.timer < TIMER_INTERVAL:
#            self.animate_actions(self.actions, self.timer/float(TIMER_INTERVAL))
#
#        if self.timer == TIMER_INTERVAL:
#            self.next_actions = self.apply_actions(self.actions)
#
#        self.timer = (self.timer + 1) % (TIMER_INTERVAL+1)
func _process(delta):
    if self.mode == PLAY:
        self.timer += clamp(delta, 0, SECONDS_PER_STEP)
        if self.timer >= SECONDS_PER_STEP:
            self.next_actions = self.apply_actions(self.actions)
            self.actions = self.compute_actions(self.next_actions)
            self.timer -= SECONDS_PER_STEP
        self.animate_actions(self.actions, self.timer/SECONDS_PER_STEP)


func clear_level():
    self.current_chest = 0
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
        # Filling in blanks if they don't exist.
        var element = Global.ALL_ELEMENTS['blank'].instance().setup(x, y)
        self.element_map[[x,y]] = element
        $Elements.add_child(element)
        return element


func get_chest_contents():
    var result = self.chest_contents[self.current_chest]
    self.current_chest = (self.current_chest + 1) % 4
    return result


func set_element(x, y, element_name):
    if self.element_map.has([x,y]):
        var prev = self.element_map[[x,y]]
        $Elements.remove_child(prev)
        prev.queue_free()
    var element = Global.ALL_ELEMENTS[element_name].instance().setup(x, y)
    $Elements.add_child(element)
    self.element_map[[x,y]] = element
    if element.is_player():
        self.player_ref = element


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
    if x >= 1 and y >= 1 and x < LEVEL_SIZE.x-1 and y < LEVEL_SIZE.y-1:
        self.set_element(x, y, element_name)


func get_element_by_pixel(position):
    var x = int(position.x/Global.TILE_SIZE)
    var y = int(position.y/Global.TILE_SIZE)
    return self.element_map[[x,y]].get_element_name()


func to_json_():
    var element_map_names = []
    for y in range(self.LEVEL_SIZE.y):
        var row = []
        for x in range(self.LEVEL_SIZE.x):
            row.append(self.element_map[[x,y]].get_element_name())
        element_map_names.append(row)
    return to_json({
            'element_map_names': element_map_names,
            'coins_required': self.coins_required,
            'level_name': self.level_name,
            'chest_contents': self.chest_contents
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
    self.coins_required = dict.get('coins_required', 0)
    self.level_name = dict.get('level_name', '[unnamed level]')
    self.chest_contents = dict.get('chest_contents', self.chest_contents)


func load_from_file(level_set, level_number):
    self.level_set = level_set
    self.level_number = level_number
    var filename = 'res://levels/%s/%d.json' % [level_set, level_number]
    var file = File.new()
    if file.file_exists(filename):
        file.open(filename, File.READ)
        self.from_json(file.get_line())
        file.close()
    else:
        file.close()
        self.clear_level()
        self.save_to_file()
    

func save_to_file():
    var file = File.new()
    file.open('res://levels/%s/%d.json' % [self.level_set, self.level_number], File.WRITE)
    file.store_line(self.to_json_())
    file.close()
