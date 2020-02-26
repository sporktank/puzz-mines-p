extends "res://Element.gd"


var open = 0


func get_element_name():
    return 'exit'


func is_exit():
    return true


func compute_actions():

    # Testing this idea. -- like a "null"/Idle action each time.
    return [Actions.Wait.new(self, -10)]


func animate_action(action, alpha):
    
    if self.open:
        self.modulate.a = 0.75 + 0.25 * cos(2*PI * (self.open-2+alpha)*0.15)
    
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):

    var temp = get_parent().get_parent().coins_collected >= get_parent().get_parent().coins_required # TODO: Do this nicer.
    if self.open == 0 and temp:
        self.open = 1
        
    if self.open > 0:
        self.open += 1
    
    
    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
