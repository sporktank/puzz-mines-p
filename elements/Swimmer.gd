extends "res://Element.gd"


var facing = -1


func get_element_name():
    return 'swimmer'
    

func is_bonkable():
    return true
    
    
func get_produce():
    return [['blank', 'blank', 'blank'], ['goldcoin', 'goldcoin', 'goldcoin'], ['blank', 'blank', 'blank']]


func is_facing(element):
    return element.map_y == self.map_y+self.facing


func compute_actions():

    # Movement.
    if self.is_facing(self.s) and self.s.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 5)]
    if self.is_facing(self.n) and self.n.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y-1, 5)]
    
    # Drown.
    if self.is_facing(self.s) and self.s.is_lava():
        return [Actions.Drown.new(self, self.map_x, self.map_y+1, 10)]
    
    # Kill.
    if self.is_facing(self.s) and self.s.is_player():
        return [Actions.Explode.new(self.s, false, self.s.get_produce(), 16)]  # 2020-02-26: Changed to higher priority
    if self.is_facing(self.n) and self.n.is_player():
        return [Actions.Explode.new(self.n, false, self.n.get_produce(), 6)]
    
    # Rotate right.
    return [Actions.Rotate.new(self, null, 20)]


func animate_action(action, alpha):
    
    if action is Actions.Move or action is Actions.Drown:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        $AnimatedSprite.play('walk')
        $AnimatedSprite.frame = fmod(alpha*4, 4)
        $AnimatedSprite.stop()

    if action is Actions.Rotate:
        $AnimatedSprite.rotation = PI/2 + self.facing*PI/2 + 2*alpha*PI/2

    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
    
    $AnimatedSprite.play('still')
    $AnimatedSprite.stop()
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        
    if action is Actions.Rotate:
        self.facing *= -1
        $AnimatedSprite.rotation = PI/2 + self.facing*PI/2
    
    if action is Actions.Explode:
        if action.element == self:
            self.replace_me('explosion', {'produce':action.get_produce(self)})
        else:
            self.replace_me('explosion', {'produce':'explosion', 'explosion_produce':self.get_produce()})
    
    if action is Actions.Drown:
        self.remove_me()
