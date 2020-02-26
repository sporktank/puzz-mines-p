extends "res://Element.gd"


var exploding = false
var wait = 2


func get_element_name():
    return 'bomb'


func setup(x, y, extra_args={}):
    self.exploding = extra_args.get('exploding', false)
    return .setup(x, y, extra_args)


func is_collectable():
    return true if not self.exploding else false


func is_rollable():
    return true
    

func get_produce():
    return [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']]


func compute_actions():
    
    if self.exploding and self.wait == 0:
        return [Actions.Explode.new(self, true, self.get_produce(), 50)]
    
    return [Actions.Wait.new(self, -10)]


func animate_action(action, alpha):
    
    if self.exploding and action is Actions.Wait:
        $AnimatedSprite.frame = fmod(alpha*3, 2)
        $AnimatedSprite.scale = Vector2(0.5, 0.5) * (1 - 0.2*sin(alpha*2*PI))
    
    if action is Actions.Collect:
        self.scale = Vector2(1-alpha, 1-alpha)
        
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
    
    if self.exploding:
        self.wait -= 1
    
    if action is Actions.Collect:
        action.by.collect_bomb()
        self.remove_me()
        
    if action is Actions.Explode:
        if action.element == self:
            self.replace_me('explosion', {'produce':'blank'})
        else:
            self.replace_me('explosion', {'produce':'explosion'})
        
