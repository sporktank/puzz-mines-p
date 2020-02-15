extends "res://Element.gd"


func get_element_name():
    return 'goldcoin'


func is_rollable():
    return true
    
    
func is_collectable():
    return true
    

func compute_actions():
    
    if self.s.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 10)]
        
    if self.w.is_blank() and self.sw.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 0)]
        
    if self.e.is_blank() and self.se.is_blank() and self.s.is_rollable():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 0)]


func apply_action(action):
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        
    if action is Actions.Collect:
        self.remove_me()
        
    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
        
