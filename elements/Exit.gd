extends "res://Element.gd"


func get_element_name():
    return 'exit'


func is_exit():
    return true


func compute_actions():

    # Testing this idea. -- like a "null"/Idle action each time.
    return [Actions.Wait.new(self, -10)]


func animate_action(action, alpha):
    
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):

    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
