extends "res://Element.gd"


func get_element_name():
    return 'blank'


func is_blank():
    return true


func is_collectable():
    return true


func animate_action(action, alpha):

    if action is Actions.Explode:
        self.animate_explode(alpha)

func apply_action(action):
        
    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
