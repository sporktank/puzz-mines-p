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
        
        # If all actions are moves, take top priority action only.
        if num_all == num_move:
            for i in range(0, num_all-1):
                list[i].invalidate()
            return
            
        # If one move and one collect, that's fine.
        if num_move == 1 and num_collect == 1 and num_all == 2:
            return
        
        print('Unhandled conflict of %d actions (taking top priority action only by default):' % [num_all])
        for action in list:
            print(action.to_string())
        print('.')
        for i in range(0, num_all-1):
            list[i].invalidate()


class ActionResult:
    var delete_me
    func _init(delete_me):
        self.delete_me = delete_me
        

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
    

class Move extends Action:
    var x
    var y
    func _init(element, x, y, priority):
        self.element = element
        self.x = x
        self.y = y
        self.priority = priority
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [x, y]]
    func to_string():
        return 'Move(%s, dx=%d, dy=%d)' % [self.element.get_element_name(), self.x-self.element.map_x, self.y-self.element.map_y]
        

class Collect extends Action:
    var by
    func _init(element, by, priority):
        self.element = element
        self.by = by
        self.priority = priority
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y]]#, [self.by.map_x, self.by.map_y]]
    func to_string():
        return 'Collect(%s, by=%s)' % [self.element.get_element_name(), self.by.get_element_name()]
        

class Push extends Action:
    var by
    var x
    var y
    func _init(element, by, x, y, priority):
        self.element = element
        self.by = by
        self.x = x
        self.y = y
        self.priority = priority
    func get_elements():
        return [self.by, self.element]  # NOTE: Sublte order dependency here.. might try to remove this.
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y], [self.by.map_x, self.by.map_y], [self.x, self.y]]
    func to_string():
        return 'Push(%s, by=%s, dx=%d, dy=%d)' % [self.element.get_element_name(), self.by.get_element_name(), self.x-self.element.map_x, self.y-self.element.map_y]
        
        
class Rotate extends Action:
    var cw
    func _init(element, cw, priority):
        self.element = element
        self.cw = cw
        self.priority = priority
    func get_all_xy():
        return [[self.element.map_x, self.element.map_y]]
    func to_string():
        return 'Rotate(%s, cw=%d)' % [self.element.get_element_name(), self.cw]
        