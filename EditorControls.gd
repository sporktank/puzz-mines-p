extends Node2D


var left_element = 'blank'
var right_element = 'blank'

var _last_left_element = 'blank'


func _ready():
    for element_name in Global.ALL_ELEMENTS:
        var element = Global.ALL_ELEMENTS[element_name].instance()
        $ElementList.add_item(element_name, element.get_still_texture())
    self.update_buttons()
    

func update_buttons():
    $LeftElement.texture = Global.ALL_ELEMENTS[self.left_element].instance().get_still_texture()
    $RightElement.texture = Global.ALL_ELEMENTS[self.right_element].instance().get_still_texture()


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
