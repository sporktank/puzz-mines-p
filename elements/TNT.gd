extends "res://Element.gd"


var falling = false


func get_element_name():
    return 'tnt'


func is_rollable():
    return true


func is_pushable():
    return true
    
    
func is_bonkable():
    return true


func get_produce():
    return [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']]


func compute_actions():

    if self.s.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 10)]

    if self.s.is_lava():
        return [Actions.Drown.new(self, self.map_x, self.map_y+1, 10)]

    if self.falling and not self.s.is_blank():
        return [Actions.Explode.new(self, true, self.get_produce(), 50)]

    if self.w.is_blank() and self.sw.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 0)]
        
    if self.e.is_blank() and self.se.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 0)]

#    # Testing this idea. -- like a "null"/Idle action each time.
#    return [Actions.Wait.new(self, -10)]


func animate_action(action, alpha):
    
    if action is Actions.Move or (action is Actions.Push and action.element == self) or action is Actions.Drown:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):

    self.falling = false
    if action is Actions.Move:
        if action.y == self.map_y+1:
            self.falling = true
        self.setup(action.x, action.y)

    if action is Actions.Push and action.element == self:
        self.setup(action.x, action.y)

    if action is Actions.Explode:
        #var repl = 
        #self.replace_me('explosion', ['blank'])
        if action.element == self:
            self.replace_me('explosion', {'produce':'blank'})
        else:
            self.replace_me('explosion', {'produce':'explosion'})
        #    return [Actions.Explode.new(repl, [], self.get_produce(), 50)]

    if action is Actions.Drown:
        self.remove_me()
