extends "res://Element.gd"


var wait = 1
var produce
var explosion_produce


func setup(x, y, extra_args={}):
    self.produce = extra_args.get('produce', 'blank')
    self.explosion_produce = extra_args.get('explosion_produce', [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']])
    return .setup(x, y, extra_args)


func get_element_name():
    return 'explosion'


func compute_actions():
    
    if self.produce == 'explosion':
        return [Actions.Explode.new(self, true, self.explosion_produce, 50)]
    
    return [Actions.Wait.new(self, 40)]


func apply_action(action):
    
    if self.wait == 0 and action is Actions.Wait:
        self.replace_me(self.produce)
    self.wait = 0
    $AnimatedSprite.rotation = PI/4
        
#    if self.produce == 'explosion':
#        print('new explosion!')
#        return [Actions.Explode.new(self, self.get_neighbourhood(), [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']], 50)]
    
    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
