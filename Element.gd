extends Node2D


const FACING_ROTATE = [
        {
            [-1, 0]: [ 0, 1],
            [ 0, 1]: [ 1, 0],
            [ 1, 0]: [ 0,-1],
            [ 0,-1]: [-1, 0],
        },
        {
            [-1, 0]: [ 0,-1],
            [ 0,-1]: [ 1, 0],
            [ 1, 0]: [ 0, 1],
            [ 0, 1]: [-1, 0],
        }
    ]
        

var map_x
var map_y

var parity = 1

# Neighbourhood
var nw
var n
var ne
var w
var e
var sw
var s
var se


func to_string():
    return 'Element(type=%s, x=%d, y=%d)' % [self.get_element_name(), self.map_x, self.map_y]


func setup(x, y, extra_args={}):
    self.map_x = x
    self.map_y = y
    self.position = (Vector2(x, y) + Vector2(0.5, 0.5)) * Global.TILE_SIZE
    return self


func remove_me():
    get_parent().remove_child(self)
    self.queue_free()


func replace_me(element_name, extra_args={}):
    var element = Global.ALL_ELEMENTS[element_name].instance().setup(self.map_x, self.map_y, extra_args)
    get_parent().add_child(element)
    self.remove_me()
    return element
#func replace_me(element_name, extra_args={}):
#    print(self.get_element_name(), ' ', element_name)
#    var element = Global.ALL_ELEMENTS[element_name].instance().setup(self.map_x, self.map_y, extra_args)
#    get_parent().add_child(element)
#    element.set_neighbourhood(self.nw, self.n, self.ne, self.w, self.e, self.sw, self.s, self.se)
#    element.ne.sw = element
#    element.n.s = element
#    element.nw.se = element
#    element.e.w = element
#    element.w.e = element
#    element.se.nw = element
#    element.s.n = element
#    element.sw.ne = element
#    get_parent().get_parent().element_map[[self.map_x, self.map_y]] = element # This is hacky!
#    self.remove_me()
#    return element


func set_neighbourhood(nw, n, ne, w, e, sw, s, se):
    self.nw = nw
    self.n = n
    self.ne = ne
    self.w = w
    self.e = e
    self.sw = sw
    self.s = s
    self.se = se


func get_neighbourhood():
    return [self.nw, self.n, self.ne, self.w, self.e, self.sw, self.s, self.se]


func next_parity():
    self.parity *= -1
    return self.parity
    
    
func get_still_texture():
    return $AnimatedSprite.frames.get_frame('still', 0)


func get_element_name():
    return null


func is_blank():
    return false
    

func is_rollable():
    return false


func is_collectable():
    return false
    

func is_pushable():
    return false
    

func is_bonkable():
    return false


func get_produce():
    pass


func compute_actions():
    pass
    

func apply_action(action):
    pass
