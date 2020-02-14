extends "res://Element.gd"


func get_element_name():
    return 'rock'


func is_rollable():
    return true
    

func is_pushable():
    return true


#func compute_actions(nh):
#
#    # Falling.
#    if nh.s.is_blank():
#        self.add_action(MOVE_S)
#        nh.s.add_action(MOVE_N)
#
#    # Roll left.
#    if nh.w.is_blank() and nh.sw.is_blank() and nh.s.is_rollable():
#        self.add_action(MOVE_W)
#        nh.w.add_action(MOVE_E)
#
#    # Roll left.
#    if nh.e.is_blank() and nh.se.is_blank() and nh.s.is_rollable():
#        self.add_action(MOVE_E)
#        nh.e.add_action(MOVE_W)
#func compute_actions():
#
#    # Falling.
#    if self.s.is_blank():
#        self.add_action(MOVE_S)
#
#    # Roll left.
#    if self.w.is_blank() and self.sw.is_blank() and self.s.is_rollable():
#        self.add_action(MOVE_W)
#
#    # Roll left.
#    if self.e.is_blank() and self.se.is_blank() and self.s.is_rollable():
#        self.add_action(MOVE_E)
func compute_actions():
    
    if self.s.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 10)]
        
    if self.w.is_blank() and self.sw.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 0)]
        
    if self.e.is_blank() and self.se.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 0)]


func apply_action(action):
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        
    if action is Actions.Push and action.element == self:
        self.setup(action.x, action.y)
    