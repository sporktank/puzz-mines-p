extends "res://Element.gd"


func get_color():
    return self.get_element_name().replace('door', '')


func is_door():
    return true
