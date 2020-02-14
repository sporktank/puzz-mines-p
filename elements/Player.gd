extends "res://Element.gd"


func get_element_name():
    return 'player'


#func compute_actions():
#
#    # Movement.
#    if Input.is_action_pressed("move_left") and self.w.is_collectable():
#        self.add_action(MOVE_W)
#        self.w.add_action(COLLECT_E)
#    elif Input.is_action_pressed("move_right") and self.e.is_collectable():
#        self.add_action(MOVE_E)
#        self.e.add_action(COLLECT_W)
#    elif Input.is_action_pressed("move_up") and self.n.is_collectable():
#        self.add_action(MOVE_N)
#        self.n.add_action(COLLECT_S)
#    elif Input.is_action_pressed("move_down") and self.s.is_collectable():
#        self.add_action(MOVE_S)
#        self.s.add_action(COLLECT_N)
func compute_actions():
        
    # Move left.
    if Input.is_action_pressed("move_left") and self.w.is_collectable():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 5)] + ([] if self.w.is_blank() else [Actions.Collect.new(self.w, self, 12)])
    
    # Move right.
    if Input.is_action_pressed("move_right") and self.e.is_collectable():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 5)] + ([] if self.e.is_blank() else [Actions.Collect.new(self.e, self, 12)])
    
    # Move up.
    if Input.is_action_pressed("move_up") and self.n.is_collectable():
        return [Actions.Move.new(self, self.map_x, self.map_y-1, 5)] + ([] if self.n.is_blank() else [Actions.Collect.new(self.n, self, 12)])
                
    # Move down.
    if Input.is_action_pressed("move_down") and self.s.is_collectable():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 15)] + ([] if self.s.is_blank() else [Actions.Collect.new(self.s, self, 12)])
        
    # Push left.
    if Input.is_action_pressed("move_left") and self.w.is_pushable() and self.w.w.is_blank():
        return [Actions.Push.new(self.w, self, self.map_x-2, self.map_y, 3)]
        
    # Push right.
    if Input.is_action_pressed("move_right") and self.e.is_pushable() and self.e.e.is_blank():
        return [Actions.Push.new(self.e, self, self.map_x+2, self.map_y, 3)]
        

func apply_action(action):
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        
    if action is Actions.Push and action.by == self:
        self.setup(action.element.map_x, action.element.map_y)
