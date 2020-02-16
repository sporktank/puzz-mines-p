extends "res://Element.gd"


func get_element_name():
    return 'grass'


func is_collectable():
    return true


func animate_action(action, alpha):

    if action is Actions.Collect:
        var f = Global.TILE_SIZE
        var h = Global.TILE_SIZE/2.0
        var a = alpha*Global.TILE_SIZE
        if action.by.map_x < self.map_x:
            $Black.rect_position = Vector2(-h, -h)
            $Black.rect_size = Vector2(a, f)
        elif action.by.map_x > self.map_x:
            $Black.rect_position = Vector2(h-a, -h)
            $Black.rect_size = Vector2(a+1, f)
        elif action.by.map_y < self.map_y:
            $Black.rect_position = Vector2(-h, -h)
            $Black.rect_size = Vector2(f, a)
        elif action.by.map_y > self.map_y:
            $Black.rect_position = Vector2(-h, h-a)
            $Black.rect_size = Vector2(f, a+1)
        
    if action is Actions.Explode:
        self.animate_explode(alpha)
        

func apply_action(action):
    
    if action is Actions.Collect:
        self.remove_me()
        
    if action is Actions.Explode:
         self.replace_me('explosion', {'produce':action.get_produce(self)})
