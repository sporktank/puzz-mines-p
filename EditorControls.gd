extends Node2D


var left_element = 'blank'
var right_element = 'blank'

var _last_left_element = 'blank'

var chest_number = 1
var chest_contents = [
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']],
        [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']]
    ]


func _ready():
    for element_name in Global.ALL_ELEMENTS:
        var element = Global.ALL_ELEMENTS[element_name].instance()
        $ElementList.add_item(element_name, element.get_still_texture())
    self.update_buttons()
    self.update_chest()
    

func update_buttons():
    $LeftElement.texture = Global.ALL_ELEMENTS[self.left_element].instance().get_still_texture()
    $RightElement.texture = Global.ALL_ELEMENTS[self.right_element].instance().get_still_texture()


func update_chest():
    for y in range(3):
        for x in range(3):
            get_node("Chest"+str(x+1)+str(y+1)).texture = Global.ALL_ELEMENTS[self.chest_contents[self.chest_number-1][x][y]].instance().get_still_texture()


func _on_ElementList_item_selected(index):
    self._last_left_element = self.left_element
    self.left_element = $ElementList.get_item_text(index)
    $ElementList.unselect_all()
    self.update_buttons()


func _on_ElementList_item_rmb_selected(index, at_position):
    self.right_element = $ElementList.get_item_text(index)
    self.left_element = self._last_left_element
    $ElementList.unselect_all()
    self.update_buttons()


func _on_ChestNumber_value_changed(value):
    self.chest_number = value
    self.update_chest()


func _chest_click(event, x, y):
    if event is InputEventMouseButton and event.pressed:
        var element = self.left_element if event.button_mask == 1 else self.right_element
        self.chest_contents[self.chest_number-1][x][y] = element
        self.update_chest()

func _on_Chest11_gui_input(event): self._chest_click(event, 0, 0)
func _on_Chest12_gui_input(event): self._chest_click(event, 0, 1)
func _on_Chest13_gui_input(event): self._chest_click(event, 0, 2)
func _on_Chest21_gui_input(event): self._chest_click(event, 1, 0)
func _on_Chest22_gui_input(event): self._chest_click(event, 1, 1)
func _on_Chest23_gui_input(event): self._chest_click(event, 1, 2)
func _on_Chest31_gui_input(event): self._chest_click(event, 2, 0)
func _on_Chest32_gui_input(event): self._chest_click(event, 2, 1)
func _on_Chest33_gui_input(event): self._chest_click(event, 2, 2)
