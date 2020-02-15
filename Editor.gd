extends Node2D


func _ready():
    $EditorControls/Clear.connect('pressed', self, '_on_Clear_pressed')
    $EditorControls/Save.connect('pressed', self, '_on_Save_pressed')
    $Level.set_edit_mode()
    $Level.load_from_file()


func _process(delta):
    if Input.is_action_pressed("ui_cancel"):
        get_tree().quit()


func _on_LevelOverlay_gui_input(event):
    if event is InputEventMouse:
        if event.button_mask == 1:
            $Level.set_element_by_pixel($EditorControls.left_element, event.position)
        elif event.button_mask == 2:
            $Level.set_element_by_pixel($EditorControls.right_element, event.position)


func _on_Clear_pressed():
    $Level.clear_level()


func _on_Save_pressed():
    $Level.save_to_file()
    
