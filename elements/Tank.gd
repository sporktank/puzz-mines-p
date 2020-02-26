extends "res://Element.gd"


var facing = 1
var last_push = false


func get_element_name():
    return 'tank'


func is_facing(element):
    return element.map_x == self.map_x+self.facing


func compute_actions():

    #if self.last_push:
    #    return [Actions.Rotate.new(self, null, 20)]

    # Movement.
    if self.is_facing(self.w) and self.w.is_blank():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 5)]
    if self.is_facing(self.e) and self.e.is_blank():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 5)]
    
    # Push.
    if not self.last_push and self.is_facing(self.w) and self.w.is_pushable() and self.w.w.is_blank():
        return [Actions.Push.new(self.w, self, self.map_x-2, self.map_y, 3), Actions.Rotate.new(self, null, 20)]
    if not self.last_push and self.is_facing(self.e) and self.e.is_pushable() and self.e.e.is_blank():
        return [Actions.Push.new(self.e, self, self.map_x+2, self.map_y, 3), Actions.Rotate.new(self, null, 20)]
    
    # Kill.
    if self.is_facing(self.w) and self.w.is_player():
        return [Actions.Explode.new(self.w, false, self.w.get_produce(), 4)]  # Lower priority allowing player to walk past.
    if self.is_facing(self.e) and self.e.is_player():
        return [Actions.Explode.new(self.e, false, self.e.get_produce(), 4)]
    
    # Rotate right.
    return [Actions.Rotate.new(self, null, 20)]


func animate_action(action, alpha):
    
    if action is Actions.Move:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        #$AnimatedSprite.play('walk')
        #$AnimatedSprite.frame = fmod(alpha*4, 4)
        #$AnimatedSprite.stop()

    if action is Actions.Rotate:
        #$AnimatedSprite.scale = 0.5*Vector2(self.facing - 2*self.facing*alpha, 1)
        $AnimatedSprite.scale = 0.5*Vector2(-self.facing, 1)

#    if action is Actions.Explode:
#        self.animate_explode(alpha)


func apply_action(action):
    
    #$AnimatedSprite.play('still')
    #$AnimatedSprite.stop()
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        
    self.last_push = false
    if action is Actions.Push and action.by == self:
        self.last_push = true
        
    if action is Actions.Rotate:
        self.facing *= -1
        $AnimatedSprite.scale = 0.5*Vector2(self.facing, 1)
    
#    if action is Actions.Explode:
#        if action.element == self:
#            self.replace_me('explosion', {'produce':action.get_produce(self)})
#        else:
#            self.replace_me('explosion', {'produce':'explosion', 'explosion_produce':self.get_produce()})
