extends "res://Element.gd"


const INTEND_MIN = 0.6
const INTEND_MAX = 0.99


var intend_left = false
var intend_right = false
var intend_up = false
var intend_down = false


func get_element_name():
    return 'player'


func is_player():
    return true
    
    
func is_bonkable():
    return true


func get_produce():
    return [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']]


func compute_actions():
        
    # Move left.
    if self.intend_left and self.w.is_collectable():
        return [Actions.Move.new(self, self.map_x-1, self.map_y, 5)] + ([] if self.w.is_blank() else [Actions.Collect.new(self.w, self, 5)])
    
    # Move right.
    if self.intend_right and self.e.is_collectable():
        return [Actions.Move.new(self, self.map_x+1, self.map_y, 5)] + ([] if self.e.is_blank() else [Actions.Collect.new(self.e, self, 5)])
    
    # Move up.
    if self.intend_up and self.n.is_collectable():
        return [Actions.Move.new(self, self.map_x, self.map_y-1, 5)] + ([] if self.n.is_blank() else [Actions.Collect.new(self.n, self, 5)])
                
    # Move down.
    if self.intend_down and self.s.is_collectable():
        return [Actions.Move.new(self, self.map_x, self.map_y+1, 15)] + ([] if self.s.is_blank() else [Actions.Collect.new(self.s, self, 15)])
        
    # Push left.
    if self.intend_left and self.w.is_pushable() and self.w.w.is_blank():
        return [Actions.Push.new(self.w, self, self.map_x-2, self.map_y, 3)]
        
    # Push right.
    if self.intend_right and self.e.is_pushable() and self.e.e.is_blank():
        return [Actions.Push.new(self.e, self, self.map_x+2, self.map_y, 3)]
        
    # Push up.
    if self.intend_up and self.n.is_vpushable() and self.n.n.is_blank():
        return [Actions.Push.new(self.n, self, self.map_x, self.map_y-2, 3)]
        
    # Push down.
    if self.intend_down and self.s.is_pushable() and self.s.s.is_blank():
        return [Actions.Push.new(self.s, self, self.map_x, self.map_y+2, 3)]
        
    # Exit.
    var temp = get_parent().get_parent().coins_collected >= get_parent().get_parent().coins_required # TODO: Do this nicer.
    if self.intend_left and self.w.is_exit() and temp:
        return [Actions.Exit.new(self, self.w, 9)]
    if self.intend_right and self.e.is_exit() and temp:
        return [Actions.Exit.new(self, self.e, 9)]
    if self.intend_up and self.n.is_exit() and temp:
        return [Actions.Exit.new(self, self.n, 9)]
    if self.intend_down and self.s.is_exit() and temp:
        return [Actions.Exit.new(self, self.s, 9)]

    # Testing this idea. -- like a "null"/Idle action each time.
    return [Actions.Wait.new(self, -10)]
    

func _animate_walk(dx, dy, push, alpha):
    
    if dx < 0:
        $AnimatedSprite.play('walk_left')
    elif dx > 0:
        $AnimatedSprite.play('walk_right')
    elif dy < 0:
        $AnimatedSprite.play('walk_up')
    elif dy > 0:
        $AnimatedSprite.play('walk_down')
    
    $AnimatedSprite.frame = fmod((int(push)+1)*4.0*alpha, 4.0)
    $AnimatedSprite.stop()
    

func animate_action(action, alpha):
    
    # TODO: Still a work-in-progress!
    if alpha < INTEND_MIN:
        self.intend_left = false
        self.intend_right = false
        self.intend_up = false
        self.intend_down = false
    elif INTEND_MIN <= alpha and alpha <= INTEND_MAX:
        if Input.is_action_pressed("move_left"):
            self.intend_left = true
            self.intend_right = false
        elif Input.is_action_pressed("move_right"):
            self.intend_left = false
            self.intend_right = true
        if Input.is_action_pressed("move_up"):
            self.intend_up = true
            self.intend_down = false
        elif Input.is_action_pressed("move_down"):
            self.intend_up = false
            self.intend_down = true
    
    if action is Actions.Move:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        self._animate_walk(action.x-self.map_x, action.y-self.map_y, false, alpha)
        
    if action is Actions.Push and action.by == self:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.element.map_x, action.element.map_y)*alpha
        self._animate_walk(action.element.map_x-self.map_x, action.element.map_y-self.map_y, true, alpha)

    if action is Actions.Exit:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.exit.map_x, action.exit.map_y)*alpha
        self._animate_walk(action.exit.map_x-self.map_x, action.exit.map_y-self.map_y, false, alpha)
        self.scale = Vector2(1-alpha, 1-alpha)

    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
    
    if action is Actions.Move:
        self.setup(action.x, action.y)
        self._animate_walk(action.x-self.map_x, action.y-self.map_y, false, 0.0)
        
    if action is Actions.Push and action.by == self:
        self.setup(action.element.map_x, action.element.map_y)
        self._animate_walk(action.element.map_x-self.map_x, action.element.map_y-self.map_y, true, 0.0)
        
    if action is Actions.Exit:
        self.remove_me()
        
#    if action is Actions.Crush and action.element == self:
#        #self.remove_me()
#        return [Actions.Explode.new(self, self.get_neighbourhood(), 50)]
        
    if action is Actions.Explode:
        if action.element == self:
            self.replace_me('explosion', {'produce':'blank'})
        else:
            self.replace_me('explosion', {'produce':'explosion'})
