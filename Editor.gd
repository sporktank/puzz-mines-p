extends Node2D


var ctrl_click = false


func _ready():
    for level_set in Global.ALL_LEVEL_SETS:
        $EditorControls/LevelSet.add_item(level_set)
    $EditorControls/LevelSet.text = Global.current_level_set
    $EditorControls/LevelNumber.value = Global.current_level_number
    $EditorControls/Clear.connect('pressed', self, '_on_Clear_pressed')
    $EditorControls/Save.connect('pressed', self, '_on_Save_pressed')
    $EditorControls/SaveAndTest.connect('pressed', self, '_on_SaveAndTest_pressed')
    $EditorControls/Coins.connect('value_changed', self, '_on_Coins_value_changed')
    $EditorControls/LevelSet.connect('item_selected', self, '_on_LevelSet_item_selected')
    $EditorControls/LevelNumber.connect('value_changed', self, '_on_LevelNumber_value_changed')
    $EditorControls/LevelName.connect('text_changed', self, '_on_LevelName_text_changed')
    $Level.set_edit_mode()
    self.load_in_editor()
    Global.on_exit = 'editor'
    
    
func load_in_editor():
    $Level.load_from_file($EditorControls/LevelSet.text, $EditorControls/LevelNumber.value)
    $EditorControls/Coins.value = $Level.coins_required
    $EditorControls/LevelName.text = $Level.level_name
    $EditorControls.chest_contents = $Level.chest_contents
    $EditorControls.update_chest()


func _process(delta):
    
    $Level.chest_contents = $EditorControls.chest_contents
    
    if Input.is_action_just_pressed("save"):
        self._on_Save_pressed()
        
    if Input.is_action_just_pressed("test"):
        self._on_SaveAndTest_pressed()
        
    if Input.is_action_just_pressed("exit"):
        get_tree().quit()


func _input(event):
    if event is InputEventKey and event.scancode == KEY_CONTROL:
        self.ctrl_click = event.pressed


func _on_LevelOverlay_gui_input(event):
    if event is InputEventMouse:
        if event.button_mask == 1:
            if self.ctrl_click:
                $EditorControls.left_element = $Level.get_element_by_pixel(event.position)
                $EditorControls.update_buttons()
            else:
                $Level.set_element_by_pixel($EditorControls.left_element, event.position)
        elif event.button_mask == 2:
            if self.ctrl_click:
                $EditorControls.right_element = $Level.get_element_by_pixel(event.position)
                $EditorControls.update_buttons()
            else:
                $Level.set_element_by_pixel($EditorControls.right_element, event.position)


func _on_Clear_pressed():
    $Level.clear_level()
    $EditorControls.chest_contents = [
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']]
    ]


func _on_SaveAndTest_pressed():
    $Level.save_to_file()
    Global.test_level($EditorControls/LevelSet.text, $EditorControls/LevelNumber.value)
    

func _on_Save_pressed():
    $Level.save_to_file()
    

func _on_Coins_value_changed(value):
    $Level.coins_required = $EditorControls/Coins.value


func _on_LevelSet_item_selected(id):
    self.load_in_editor()
    
    
func _on_LevelNumber_value_changed(value):
    self.load_in_editor()
    
    
func _on_LevelName_text_changed(new_text):
    $Level.level_name = new_text
