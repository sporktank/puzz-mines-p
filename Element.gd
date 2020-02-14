extends Node2D


#enum {TO_N, TO_W, TO_E, TO_S, FROM_N, FROM_W, FROM_E, FROM_S}
#enum {MOVE_N, MOVE_W, MOVE_E, MOVE_S, COLLECT_N, COLLECT_W, COLLECT_E, COLLECT_S}
#
#class ActionResult:
#    var new_map_x
#    var new_map_y
#    var delete_element
#    var new_element
#    func _init(new_map_x, new_map_y, delete_element, new_element):
#        self.new_map_x = new_map_x
#        self.new_map_y = new_map_y
#        self.delete_element = delete_element
#        self.new_element = new_element
        

var map_x
var map_y

#var possible_actions = []

var parity = 1

# Neighbourhood
var nw
var n
var ne
var w
var e
var sw
var s
var se


func to_string():
    return 'Element(type=%s, x=%d, y=%d)' % [self.get_element_name(), self.map_x, self.map_y]


func setup(x, y):
    self.map_x = x
    self.map_y = y
    self.position = (Vector2(x, y) + Vector2(0.5, 0.5)) * Global.TILE_SIZE
    return self


func set_neighbourhood(nw, n, ne, w, e, sw, s, se):
    self.nw = nw
    self.n = n
    self.ne = ne
    self.w = w
    self.e = e
    self.sw = sw
    self.s = s
    self.se = se


func next_parity():
    self.parity *= -1
    return self.parity
    
    
func get_still_texture():
    return $AnimatedSprite.frames.get_frame('still', 0)


func get_element_name():
    return null


# --

func is_blank():
    return false
    

func is_rollable():
    return false


func is_collectable():
    return false
    

func is_pushable():
    return false

# --

#func reset_actions():
#    self.possible_actions = []
    

#func add_action(action):
#    self.possible_actions.append(action)
    

#func compute_actions(nh):
#    pass
#func compute_actions():
#    pass
func compute_actions():
    pass
    
    
#func _equal_actions(a, b):
#    if a.size() != b.size():
#        return false
#    for i in a:
#        if not (i in b):
#            return false
#    return true
#
#
#func resolve_actions():
#    if _equal_actions(self.possible_actions, [MOVE_W, MOVE_E]):
#        self.possible_actions.remove(self.possible_actions.find(MOVE_W if self.s.next_parity() == 1 else MOVE_E))
#    else:
#        print('Unresolved conflict!')
    
    
#func apply_action(action):
#    match action:
#        MOVE_N:
#            return ActionResult.new(self.map_x, self.map_y-1, false, null)
#        MOVE_S:
#            return ActionResult.new(self.map_x, self.map_y+1, false, null)
#        MOVE_W:
#            return ActionResult.new(self.map_x-1, self.map_y, false, null)
#        MOVE_E:
#            return ActionResult.new(self.map_x+1, self.map_y, false, null)
#        COLLECT_N, COLLECT_S, COLLECT_W, COLLECT_E:
#            return ActionResult.new(self.map_x, self.map_y, true, null)
#        _:
#            return ActionResult.new(self.map_x, self.map_y, false, null)
func apply_action(action):
    pass
