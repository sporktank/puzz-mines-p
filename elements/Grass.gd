extends "res://Element.gd"


func get_element_name():
    return 'grass'


func is_collectable():
    return true


func apply_action(action):
    
    if action is Actions.Collect:
        return Actions.ActionResult.new(true)
        