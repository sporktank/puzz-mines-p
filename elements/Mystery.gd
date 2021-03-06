extends "res://Element.gd"


func get_element_name():
    return 'mystery'


func is_pushable():
    return true

    
func is_vpushable():
    return true


func get_produce():
    #return [['steel', 'steel', 'steel'], ['steel', 'steel', 'steel'], ['steel', 'steel', 'steel']]
    return get_parent().get_parent().get_chest_contents() # Now this is hacky...


func compute_actions():

    $Number.text = str(get_parent().get_parent().current_chest + 1)

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
        if action.element == self:
            self.replace_me('explosion', {'produce':action.get_produce(self)})
        else:
            self.replace_me('explosion', {'produce':'explosion', 'explosion_produce':self.get_produce()})
