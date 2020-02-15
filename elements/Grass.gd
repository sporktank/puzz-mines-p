extends "res://Element.gd"


func get_element_name():
    return 'grass'


func is_collectable():
    return true


func apply_action(action):
    
    if action is Actions.Collect:
        self.remove_me()
        
    if action is Actions.Explode:
         self.replace_me('explosion', {'produce':action.get_produce(self)})
