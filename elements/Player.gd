extends "res://Element.gd"


const INTEND_MIN = -0.01 #0.6
const INTEND_MAX = 1.01 #0.99


const MOVE_WAIT = 0.825
var move_list = []

var intend_left = false
var intend_right = false
var intend_up = false
var intend_down = false
var intend_bomb = false
var intend_click = false

var has_collected_key = {'red':false, 'blue':false, 'green':false, 'yellow':false}
var bomb_count = 0
var last_bomb = false
var is_dead = false
var is_complete = false


func get_element_name():
    return 'player'


func is_player():
    return true
    
    
func is_bonkable():
    return true


func get_produce():
    return [['blank', 'blank', 'blank'], ['blank', 'blank', 'blank'], ['blank', 'blank', 'blank']]


func collect_key(color):
    self.has_collected_key[color] = true


func collect_bomb():
    self.bomb_count += 1


func compute_actions():
    
    # This is lame, trying to get smooth timing across all platforms.
    if Global.dummy_compute_actions:
        return
    
    self.parity *= -1
    var move_list_copy = self.move_list
    self.move_list = []
    while move_list_copy:
        var move = move_list_copy.pop_back()
        self.intend_left = int(move[0] == -1)
        self.intend_right = int(move[0] == 1)
        self.intend_up = int(move[1] == -1)
        self.intend_down = int(move[1] == 1)
        self.intend_bomb = int(move[2])
        self.intend_click = int(move[3])
        
        # Nothing.
        if not self.intend_left and not self.intend_right and not self.intend_up and not self.intend_down:
            break
    
        # Click.
        if self.intend_click:
            if self.intend_left and self.w.is_collectable() and not self.w.is_blank():
                return [Actions.Collect.new(self.w, self, 11), Actions.Wait.new(self, -10)]
            if self.intend_right and self.e.is_collectable() and not self.e.is_blank():
                return [Actions.Collect.new(self.e, self, 11), Actions.Wait.new(self, -10)]
            if self.intend_up and self.n.is_collectable() and not self.n.is_blank():
                return [Actions.Collect.new(self.n, self, 11), Actions.Wait.new(self, -10)]
            if self.intend_down and self.s.is_collectable() and not self.s.is_blank():
                return [Actions.Collect.new(self.s, self, 15), Actions.Wait.new(self, -10)]
            
        else:
            
            # Move.
            var will_bomb = self.intend_bomb and self.bomb_count > 0 and not self.last_bomb
            if self.intend_left and self.w.is_collectable():
                return [Actions.Move.new(self, self.map_x-1, self.map_y, 5, will_bomb)] + ([] if self.w.is_blank() else [Actions.Collect.new(self.w, self, 5)])
            if self.intend_right and self.e.is_collectable():
                return [Actions.Move.new(self, self.map_x+1, self.map_y, 5, will_bomb)] + ([] if self.e.is_blank() else [Actions.Collect.new(self.e, self, 5)])
            if self.intend_up and self.n.is_collectable():
                return [Actions.Move.new(self, self.map_x, self.map_y-1, 5, will_bomb)] + ([] if self.n.is_blank() else [Actions.Collect.new(self.n, self, 5)])
            if self.intend_down and self.s.is_collectable():
                return [Actions.Move.new(self, self.map_x, self.map_y+1, 5, will_bomb)] + ([] if self.s.is_blank() else [Actions.Collect.new(self.s, self, 5)])
                
            # Push.
            if self.intend_left and self.w.is_pushable() and self.w.w.is_blank():
                return [Actions.Push.new(self.w, self, self.map_x-2, self.map_y, 3)]
            if self.intend_right and self.e.is_pushable() and self.e.e.is_blank():
                return [Actions.Push.new(self.e, self, self.map_x+2, self.map_y, 3)]
            if self.intend_up and self.n.is_vpushable() and self.n.n.is_blank():
                return [Actions.Push.new(self.n, self, self.map_x, self.map_y-2, 3)]
            if self.intend_down and self.s.is_vpushable() and (self.s.s.is_blank() or self.s.s.is_lava()):
                return [Actions.Push.new(self.s, self, self.map_x, self.map_y+2, 3, self.s.s.is_lava())]
                
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
                
            # Door.
            if self.intend_left and self.w.is_door() and self.w.w.is_blank() and self.has_collected_key[self.w.get_color()]:
                return [Actions.Through.new(self, self.w, self.map_x-2, self.map_y, 9)]
            if self.intend_right and self.e.is_door() and self.e.e.is_blank() and self.has_collected_key[self.e.get_color()]:
                return [Actions.Through.new(self, self.e, self.map_x+2, self.map_y, 9)]
            if self.intend_up and self.n.is_door() and self.n.n.is_blank() and self.has_collected_key[self.n.get_color()]:
                return [Actions.Through.new(self, self.n, self.map_x, self.map_y-2, 9)]
            if self.intend_down and self.s.is_door() and self.s.s.is_blank() and self.has_collected_key[self.s.get_color()]:
                return [Actions.Through.new(self, self.s, self.map_x, self.map_y+2, 9)]

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
    
#    # TODO: Still a work-in-progress!
#    if alpha < INTEND_MIN:
#        self.intend_left = false
#        self.intend_right = false
#        self.intend_up = false
#        self.intend_down = false
#        self.intend_bomb = false
#        self.intend_click = false
#    elif INTEND_MIN <= alpha and alpha <= INTEND_MAX:
#        if Input.is_action_pressed("move_left"):
#            self.intend_left = true
#            self.intend_right = false
#        elif Input.is_action_pressed("move_right"):
#            self.intend_left = false
#            self.intend_right = true
#        if Input.is_action_pressed("move_up"):
#            self.intend_up = true
#            self.intend_down = false
#        elif Input.is_action_pressed("move_down"):
#            self.intend_up = false
#            self.intend_down = true
#        if Input.is_action_pressed("bomb"):
#            self.intend_bomb = true
#        if Input.is_action_pressed("click"):
#            self.intend_click = true
#    $Debug.text = '%s %s %s %s %s %s' % [self.intend_left, self.intend_right, self.intend_up, self.intend_down, self.intend_bomb, self.intend_click]
    var new_move
    if alpha < MOVE_WAIT:
        #self.move_list.clear()
        new_move = [
                int(Input.is_action_just_pressed("move_right")) - int(Input.is_action_just_pressed("move_left")),
                int(Input.is_action_just_pressed("move_down")) - int(Input.is_action_just_pressed("move_up")),
                int(Input.is_action_pressed("bomb")),
                int(Input.is_action_pressed("click"))
            ]
    else:
        new_move = [
                int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
                int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up")),
                int(Input.is_action_pressed("bomb")),
                int(Input.is_action_pressed("click"))
            ]
    # NOTE: Left first expression here if want to enforce a movement, seems better not to.
    if abs(new_move[0]) + abs(new_move[1]) > 0 and (self.move_list.size() == 0 or new_move != self.move_list[-1]):
        if abs(new_move[0]) + abs(new_move[1]) <= 1:
            self.move_list.append(new_move)
        else:
            # Alternate priority of vertical/horizontal movement.
            # TODO: NPS wants priority given to the direction you're already travelling..
            if self.parity > 0:
                self.move_list.append([new_move[0], 0, new_move[2], new_move[3]])
                self.move_list.append([0, new_move[1], new_move[2], new_move[3]])
            else:
                self.move_list.append([0, new_move[1], new_move[2], new_move[3]])
                self.move_list.append([new_move[0], 0, new_move[2], new_move[3]])
    $Debug.text = str(self.move_list)
#    $Debug.text = '%s %s %s %s %s %s' % [
#            Input.is_action_pressed("move_left"), 
#            Input.is_action_pressed("move_right"),
#            Input.is_action_pressed("move_up"),
#            Input.is_action_pressed("move_down"),
#            Input.is_action_pressed("bomb"),
#            Input.is_action_pressed("click")
#        ]
    
    if action is Actions.Move:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.x, action.y)*alpha
        self._animate_walk(action.x-self.map_x, action.y-self.map_y, false, alpha)
        if action.bomb:
            $Bomb.visible = true
            $Bomb.scale = Vector2(0.5*alpha, 0.5*alpha)
            $Bomb.global_position = self.screen_pos()  # Probably not the best way to do it.
        
    if action is Actions.Push and action.by == self:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.element.map_x, action.element.map_y)*alpha
        self._animate_walk(action.element.map_x-self.map_x, action.element.map_y-self.map_y, true, alpha)

    if action is Actions.Exit:
        self.position = self.screen_pos()*(1-alpha) + self.screen_pos(action.exit.map_x, action.exit.map_y)*alpha
        self._animate_walk(action.exit.map_x-self.map_x, action.exit.map_y-self.map_y, false, alpha)
        self.scale = Vector2(1-alpha, 1-alpha)

    if action is Actions.Through:
        if alpha <= 0.5:
            self.position = self.screen_pos()*(1-(2*alpha)) + self.screen_pos(action.door.map_x, action.door.map_y)*(2*alpha)
        else:
            self.position = self.screen_pos(action.door.map_x, action.door.map_y)*(1-(2*alpha-1)) + self.screen_pos(action.x, action.y)*(2*alpha-1)
        self._animate_walk(action.door.map_x-self.map_x, action.door.map_y-self.map_y, false, alpha)

    if action is Actions.Explode:
        self.animate_explode(alpha)


func apply_action(action):
    
    self.last_bomb = false
    if action is Actions.Move:
        if action.bomb:
            # TESTING
            # TODO: Put this in a base function.
            var element = Global.ALL_ELEMENTS['bomb'].instance().setup(self.map_x, self.map_y, {'exploding':true})
            get_parent().add_child(element)
            get_parent().get_parent().element_map[[self.map_x, self.map_y]] = element
            $Bomb.visible = false
            # .
            self.bomb_count -= 1
            self.last_bomb = true
        self.setup(action.x, action.y)
        self._animate_walk(action.x-self.map_x, action.y-self.map_y, false, 0.0)
        
    if action is Actions.Push and action.by == self:
        self.setup(action.element.map_x, action.element.map_y)
        self._animate_walk(action.element.map_x-self.map_x, action.element.map_y-self.map_y, true, 0.0)
        
    if action is Actions.Exit:
        Global.progress_level()
        self.is_dead = true  # Might not need this?
        self.is_complete = true
        self.remove_me()
        
    if action is Actions.Through:
        self.setup(action.x, action.y)
        self._animate_walk(action.x-self.map_x, action.y-self.map_y, false, 0.0)
        
#    if action is Actions.Crush and action.element == self:
#        #self.remove_me()
#        return [Actions.Explode.new(self, self.get_neighbourhood(), 50)]
        
    if action is Actions.Explode:
        self.is_dead = true
        if action.element == self:
            self.replace_me('explosion', {'produce':'blank'})
        else:
            self.replace_me('explosion', {'produce':'explosion'})
