extends Node


class ActionMap:
    
    var actions = {}
    
    func _init(size):
        for y in range(size.y):
            for x in range(size.x):
                self.actions[[x,y]] = []
    
    func add_action(action):
        if action:
            for xy in action.get_all_xy():
                self.actions[xy].append(action)
    
    func get_actions():
        var result = []
        for actions in self.actions.values():
            for action in actions:
                if not (action in result) and action.valid:
                    result.append(action)
        return result
        
    func comp_priority(a, b):
        return a.priority < b.priority
        
    func resolve_conflicts():
        # TODO: Might need to make iterative.
        for action_list in self.actions.values(): 
            if action_list.size() > 1:
                action_list.sort_custom(self, "comp_priority")
                self.resolve_conflict(action_list)
    
    func _count_class(list, class_):
        var result = 0
        for item in list:
            if item is class_:
                result += 1
        return result
    
    # NOTE: This could end up becoming a mega-function, resolving conflicts between actions..
    # TODO: Wanted this function to be outside of this class, still learning GDScript..
    func resolve_conflict(list):
        
        var num_all = list.size()
        var num_move = _count_class(list, Actions.Move)
        var num_collect = _count_class(list, Actions.Collect)
        var num_explode = _count_class(list, Actions.Explode)
        var num_wait = _count_class(list, Actions.Wait)
        var num_push = _count_class(list, Actions.Push)
        var num_rotate = _count_class(list, Actions.Rotate)
        
        # If all actions are moves, take top priority action only.
        if num_all == num_move:
            for i in range(0, num_all-1):
                list[i].invalidate()
            return
            
        # If one move and one collect, that's fine.
        #if num_move == 1 and num_collect == 1 and num_all == 2:
        #    return
            
        # Or also including a wait, that's fine.
        if num_move == 1 and num_collect == 1 and num_wait == 1 and num_all == 3:
            return
        
        # If one wait and one collect, that's fine.
        if num_wait == 1 and num_collect == 1 and num_all == 2:
            return
            
        # If one wait and one push, that's fine.
        if num_wait == 1 and num_push == 1 and num_all == 2:
            return
            
        # If one rotate and one push, that's fine.
        if num_rotate == 1 and num_push == 1 and num_all == 2:
            return
            
        # If one wait and one explode, that's fine.
        if num_wait == 1 and num_explode == 1 and num_all == 2:
            return
            
        # If only one explosion, that takes priority.
        #if num_explode == 1:
        #    for i in range(0, num_all-1):
        #        list[i].invalidate()
        #    return
            
        # If all but one are waits, that's fine.
        #if num_wait == num_all-1:
        #    return
        
        # Multiple explosions are fine.
        #if num_explode + num_wait == num_all:
        #    return
        
        print('Unhandled conflict of %d actions (taking top priority action(s) only by default):' % [num_all])
        for action in list:
            print(action.to_string())
        print('.')
        for i in range(0, num_all):
            if list[i].priority != list[num_all-1].priority:
                list[i].invalidate()


#class ActionResult:
#    var delete_me
#    func _init(delete_me):
#        self.delete_me = delete_me
        

class Action:
    var element
    var priority = 0
    var valid = true
    func invalidate():
        self.valid = false
    func get_elements():
        return [self.element]
    func get_all_xy():
        pass
    func to_string():
        pass


class Wait extends Action:
    func _init(element, priority):
        self.element = element
        self.priority = priority
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y]]
    func to_string():
        return 'Wait(%s, priority=%d)' % [self.element.get_element_name(), self.priority]


class Move extends Action:
    var x
    var y
    var bomb
    func _init(element, x, y, priority, bomb=false):
        self.element = element
        self.x = x
        self.y = y
        self.priority = priority
        self.bomb = bomb
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [x, y]]
    func to_string():
        return 'Move(%s, dx=%d, dy=%d, priority=%d, bomb=%s)' % [self.element.get_element_name(), self.x-self.element.map_x, self.y-self.element.map_y, self.priority, self.bomb]


class Drown extends Action:
    var x
    var y
    var bomb
    func _init(element, x, y, priority, bomb=false):
        self.element = element
        self.x = x
        self.y = y
        self.priority = priority
        self.bomb = bomb
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [x, y]]
    func to_string():
        return 'Drown(%s, dx=%d, dy=%d, priority=%d, bomb=%s)' % [self.element.get_element_name(), self.x-self.element.map_x, self.y-self.element.map_y, self.priority, self.bomb]
        
        
class Exit extends Action:
    var exit
    func _init(element, exit, priority):
        self.element = element
        self.exit = exit
        self.priority = priority
    func get_elements():
        return [self.element, self.exit]
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [self.exit.map_x, self.exit.map_y]]
    func to_string():
        return 'Exit(priority=%d)' % [self.priority]
        

class Collect extends Action:
    var by
    func _init(element, by, priority):
        self.element = element
        self.by = by
        self.priority = priority
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [self.by.map_x, self.by.map_y]]
    func to_string():
        return 'Collect(%s, by=%s, priority=%d)' % [self.element.get_element_name(), self.by.get_element_name(), self.priority]
        

class Push extends Action:
    var by
    var x
    var y
    var drown
    func _init(element, by, x, y, priority, drown=false):
        self.element = element
        self.by = by
        self.x = x
        self.y = y
        self.priority = priority
        self.drown = drown
    func get_elements():
        return [self.by, self.element]  # NOTE: Sublte order dependency here.. might try to remove this.
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [self.by.map_x, self.by.map_y], [self.x, self.y]]
    func to_string():
        return 'Push(%s, by=%s, dx=%d, dy=%d, priority=%d, drown=%s)' % [self.element.get_element_name(), self.by.get_element_name(), self.x-self.element.map_x, self.y-self.element.map_y, self.priority, self.drown]


class Through extends Action:
    var door
    var x
    var y
    func _init(element, door, x, y, priority):
        self.element = element
        self.door = door
        self.x = x
        self.y = y
        self.priority = priority
    func get_elements():
        return [self.door, self.element]
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [self.door.map_x, self.door.map_y], [self.x, self.y]]
    func to_string():
        return 'Through(%s, door=%s, dx=%d, dy=%d, priority=%d)' % [self.element.get_element_name(), self.door.get_element_name(), self.x-self.element.map_x, self.y-self.element.map_y, self.priority]
        
        
class Rotate extends Action:
    var cw
    func _init(element, cw, priority):
        self.element = element
        self.cw = cw
        self.priority = priority
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y]]
    func to_string():
        return 'Rotate(%s, cw=%s, priority=%d)' % [self.element.get_element_name(), self.cw, self.priority]
        

#class Crush extends Action:
#    var by
#    func _init(element, by, priority):
#        self.element = element
#        self.by = by
#        self.priority = priority
#    func get_elements():
#        return [self.by, self.element]  # NOTE: Sublte order dependency here.. might try to remove this.
#    func get_all_xy():
#        return [[self.element.map_x, self.element.map_y], [self.by.map_x, self.by.map_y]]
#    func to_string():
#        return 'Crush(%s, by=%s)' % [self.element.get_element_name(), self.by.get_element_name()]
        

class Explode extends Action:
    var nh
    var produce
    func _init(element, nh, produce, priority):
        self.element = element
        self.nh = nh
        self.produce = produce
        self.priority = priority
    func get_elements():
        return [self.element] + (self.element.get_neighbourhood() if self.nh else [])
    func get_all_xy():
        var x = self.element.map_x
        var y = self.element.map_y
        return [[x,y]] if not self.nh else [[x-1, y-1], [x, y-1], [x+1,y-1], [x-1,y], [x,y], [x+1,y], [x-1,y+1], [x,y+1], [x+1,y+1]]
    func to_string():
        return 'Explode(%s, %d, %d, %s, priority=%d)' % [self.element.get_element_name(), self.element.map_x, self.element.map_y, self.nh, self.priority]
    func get_produce(e):
        return self.produce[1 + e.map_y - self.element.map_y][1 + e.map_x - self.element.map_x]
