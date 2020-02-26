extends "res://Element.gd"


func get_element_name():
    return 'crate'


func is_pushable():
    return true

    
func is_vpushable():
    return true


func compute_actions():

    # Testing this idea. -- like a "null"/Idle action each time.
    return [Actions.Wait.new(self, -10)]


func animate_action(action, alpha):
    
    if action is Actions.Push and action.element == self:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        
    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):

    if action is Actions.Push and action.element == self:
        if action.drown:
            self.remove_me()
        else:
            self.setup(action.x, action.y)

    if action is Actions.Explode:
        self.replace_me('explosion', {'produce':action.get_produce(self)})
