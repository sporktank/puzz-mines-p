extends "res://Element.gd"


var falling = false
var angle = 0.0


func get_element_name():
    return 'rock'


func is_rollable():
    return true
    

func is_pushable():
    return true


func compute_actions():
    
    if self.s.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 10)]
    
    if self.falling and self.s.is_bonkable():
        return [Actions.Explode.new(self.s, true, self.s.get_produce(), 50)]
        
    if self.w.is_blank() and self.sw.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 0)]
        
    if self.e.is_blank() and self.se.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 0)]
        
    if self.s.is_lava():
        return [Actions.Drown.new(self, self.map_x, self.map_y+1, 10)]

    # Testing this idea. -- like a "null"/Idle action each time.
    return [Actions.Wait.new(self, -10)]


func animate_action(action, alpha):
    
    if action is Actions.Move or (action is Actions.Push and action.element == self) or action is Actions.Drown:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        self.rotation = self.angle + alpha*(action.x - self.map_x)*PI/2
        
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
    
    self.falling = false
    if action is Actions.Move:
        self.angle += (action.x - self.map_x)*PI/2
        self.rotation = self.angle
        if action.y == self.map_y+1:
            self.falling = true
        self.setup(action.x, action.y)
        
    if action is Actions.Push and action.element == self:
        self.angle += (action.x - self.map_x)*PI/2
        self.rotation = self.angle
        self.setup(action.x, action.y)
    
#    if action is Actions.Crush and action.by == self:
#        #self.setup(action.element.map_x, action.element.map_y)
#        pass
        
    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
        
    if action is Actions.Drown:
        self.remove_me()
