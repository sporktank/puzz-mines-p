extends "res://Element.gd"


func get_color():
    return self.get_element_name().replace('key', '')


func is_collectable():
    return true


func is_rollable():
    return true
    

func animate_action(action, alpha):
    
    if action is Actions.Collect:
        self.scale = Vector2(1-alpha, 1-alpha)
        
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
        
    if action is Actions.Collect:
        action.by.collect_key(self.get_color())
        self.remove_me()
        
    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
        
