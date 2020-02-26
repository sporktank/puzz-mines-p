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
            (self.is_facing(self.w) and (self.s.is_blank() or self.s.is_lava() or self.s.is_player())) or
            (self.is_facing(self.s) and (self.e.is_blank() or self.e.is_lava() or self.e.is_player())) or
            (self.is_facing(self.e) and (self.n.is_blank() or self.n.is_lava() or self.n.is_player())) or
            (self.is_facing(self.n) and (self.w.is_blank() or self.w.is_lava() or self.w.is_player()))):
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
    
    # Drown.
    if self.is_facing(self.s) and self.s.is_lava():
        return [Actions.Drown.new(self, self.map_x, self.map_y+1, 10)]
    
    # Kill.
    if self.is_facing(self.w) and self.w.is_player():
        return [Actions.Explode.new(self.w, false, self.w.get_produce(), 4)]  # Lower priority allowing player to walk past.
    if self.is_facing(self.s) and self.s.is_player():
        return [Actions.Explode.new(self.s, false, self.s.get_produce(), 4)]
    if self.is_facing(self.e) and self.e.is_player():
        return [Actions.Explode.new(self.e, false, self.e.get_produce(), 4)]
    if self.is_facing(self.n) and self.n.is_player():
        return [Actions.Explode.new(self.n, false, self.n.get_produce(), 4)]
    
    # Rotate right.
    return [Actions.Rotate.new(self, true, 20)]


func animate_action(action, alpha):
    
    if action is Actions.Move or action is Actions.Drown:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        $AnimatedSprite.play('walk')
        $AnimatedSprite.frame = fmod(alpha*0, 2)  # Disabling, I think it doens't look good.
        $AnimatedSprite.stop()

    if action is Actions.Rotate:
        # TODO: This looks quite ugly.
        $AnimatedSprite.rotation = Vector2(-self.facing[0], -self.facing[1]).angle() + (2*int(action.cw)-1)*PI/2*alpha

    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
    
    $AnimatedSprite.play('still')
    $AnimatedSprite.stop()
    
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

    if action is Actions.Drown:
        self.remove_me()
