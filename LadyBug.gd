extends "res://Element.gd"


var facing = [-1, 0]
var last_rotate = false


func get_element_name():
    return 'ladybug'


func is_bonkable():
    return true
    
    
func get_produce():
    return [['goldcoin', 'goldcoin', 'goldcoin'], ['goldcoin', 'goldcoin', 'goldcoin'], ['goldcoin', 'goldcoin', 'goldcoin']]


func is_facing(element):
    return element.map_x == self.map_x+self.facing[0] and element.map_y == self.map_y+self.facing[1]


func compute_actions():

    # Rotate left.
    if not self.last_rotate and (
            (self.is_facing(self.w) and self.s.is_blank()) or
            (self.is_facing(self.s) and self.e.is_blank()) or
            (self.is_facing(self.e) and self.n.is_blank()) or
            (self.is_facing(self.n) and self.w.is_blank())):
        return [Actions.Rotate.new(self, false, 20)]

    # Movement.
    if self.is_facing(self.w) and self.w.is_blank():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 5)]
    if self.is_facing(self.s) and self.s.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 5)]
    if self.is_facing(self.e) and self.e.is_blank():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 5)]
    if self.is_facing(self.n) and self.n.is_blank():
        return [Actions.Move.new(self, self.map_x, self.map_y-1, 5)]
        
    # Rotate right. -- TODO: By default?
#    if (
#            (self.is_facing(self.w) and self.n.is_blank()) or
#            (self.is_facing(self.n) and self.e.is_blank()) or
#            (self.is_facing(self.e) and self.s.is_blank()) or
#            (self.is_facing(self.s) and self.w.is_blank())):
    return [Actions.Rotate.new(self, true, 20)]


func apply_action(action):
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        self.last_rotate = false
        
    if action is Actions.Rotate:
        self.facing = FACING_ROTATE[int(action.cw)][self.facing]
        $AnimatedSprite.rotation = Vector2(-self.facing[0], -self.facing[1]).angle()
        self.last_rotate = true
    
    if action is Actions.Explode:
        if action.element == self:
            self.replace_me('explosion', {'produce':action.get_produce(self)})
        else:
            self.replace_me('explosion', {'produce':'explosion', 'explosion_produce':self.get_produce()})
