extends Node2D


const MAX_MENU_ITEM = 5


var current_menu_item = 0
var current_file = 0
var current_level_set = 1
var current_level_number = 1


func _ready():
    $GoldCoin/AnimatedSprite.play('fall')
    $GoldCoin/AnimatedSprite.speed_scale = 3.0
    self.current_file = Global.current_file
    self.current_level_set = Global.ALL_LEVEL_SETS.find(Global.current_level_set)
    self.current_level_number = Global.current_level_number
    if Global.on_exit == 'menu':
        self.current_menu_item = 3
    else:
        self.current_menu_item = 0


func _process(delta):
    
    $GoldCoin.position.y += 200*delta
    if $GoldCoin.position.y > 1100:
        $GoldCoin.position = Vector2(1360 + randf()*260, -100)
        
    if Input.is_action_just_pressed("move_down") and self.current_menu_item < MAX_MENU_ITEM-1:
        self.current_menu_item += 1
    elif Input.is_action_just_pressed("move_up") and self.current_menu_item > 0:
        self.current_menu_item -= 1

    $Player.position.y = 40 + [
            $FileRight,
            $LevelSetRight,
            $LevelNumberRight,
            $PlayRight,
            $ExitRight
        ][self.current_menu_item].rect_position.y
    
    if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("click") or Input.is_action_just_pressed("ui_select"):
        match self.current_menu_item:
            0: 
                self.current_file = clamp(self.current_file + 1, 0, 3)
                self.current_level_number = Global.progress[self.current_file][Global.ALL_LEVEL_SETS[self.current_level_set]]
            1: 
                self.current_level_set = clamp(self.current_level_set + 1, 1, Global.ALL_LEVEL_SETS.size()-1)
                self.current_level_number = Global.progress[self.current_file][Global.ALL_LEVEL_SETS[self.current_level_set]]
            2: self.current_level_number = clamp(self.current_level_number + 1, 1, Global.progress[self.current_file][Global.ALL_LEVEL_SETS[self.current_level_set]])
            3: 
                Global.current_file = self.current_file
                Global.on_exit = 'menu'
                Global.test_level(Global.ALL_LEVEL_SETS[self.current_level_set], self.current_level_number)
            4: get_tree().quit()
            
    if Input.is_action_just_pressed("move_left"):
        match self.current_menu_item:
            0: 
                self.current_file = clamp(self.current_file - 1, 0, 3)
                self.current_level_number = Global.progress[self.current_file][Global.ALL_LEVEL_SETS[self.current_level_set]]
            1: 
                self.current_level_set = clamp(self.current_level_set - 1, 1, Global.ALL_LEVEL_SETS.size()-1)
                self.current_level_number = Global.progress[self.current_file][Global.ALL_LEVEL_SETS[self.current_level_set]]
            2: self.current_level_number = clamp(self.current_level_number - 1, 1, 10)
            
    $FileRight.text = '>  File: %s' % [['A', 'B', 'C', 'D'][self.current_file]]
    $LevelSetRight.text = '>  Level Set: %s' % [Global.ALL_LEVEL_SETS[self.current_level_set].substr(3, 99).to_upper()]
    $LevelNumberRight.text = '>  Level Number: %d' % [self.current_level_number]
