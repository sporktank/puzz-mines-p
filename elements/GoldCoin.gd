extends "res://Element.gd"


func get_element_name():
    return 'goldcoin'


func is_rollable():
    return true
    
    
func is_collectable():
    return true
     

func compute_actions():
    
    if self.s.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 10)]
        
    if self.w.is_blank() and self.sw.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 0)]
        
    if self.e.is_blank() and self.se.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 0)]
        
    if self.s.is_lava():
        return [Actions.Drown.new(self, self.map_x, self.map_y+1, 10)]


func animate_action(action, alpha):
    
    if action is Actions.Move or action is Actions.Drown:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        if action.y > self.map_y:
            $AnimatedSprite.play('spin')
            $AnimatedSprite.frame = 6*alpha
            $AnimatedSprite.stop()
        else:
            $AnimatedSprite.play('still')
            $AnimatedSprite.stop()

    if action is Actions.Collect:
        self.scale = Vector2(1-alpha, 1-alpha)
        
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
    
    $AnimatedSprite.play('still')
    $AnimatedSprite.stop()
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        
    if action is Actions.Collect:
        # TODO: Something nicer.
        get_parent().get_parent().coins_collected += 1
        self.remove_me()
        
    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
        
    if action is Actions.Drown:
        self.remove_me()
