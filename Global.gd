extends Node


const TILE_SIZE = 50
const MAX_LEVEL = 10

const ALL_ELEMENTS = {
    'player': preload("res://elements/Player.tscn"),
    'blank': preload("res://elements/Blank.tscn"),
    'grass': preload("res://elements/Grass.tscn"),
    'steel': preload("res://elements/Steel.tscn"),
    'rock': preload("res://elements/Rock.tscn"),
    'goldcoin': preload("res://elements/GoldCoin.tscn"),
    'ladybug': preload("res://elements/LadyBug.tscn"),
    'spider': preload("res://elements/Spider.tscn"),
    'swimmer': preload("res://elements/Swimmer.tscn"),
    'tank': preload("res://elements/Tank.tscn"),
    'explosion': preload("res://elements/Explosion.tscn"),
    'tnt': preload("res://elements/TNT.tscn"),
    'mystery': preload("res://elements/Mystery.tscn"),
    'crate': preload("res://elements/Crate.tscn"),
    'brick': preload("res://elements/Brick.tscn"),
    'exit': preload("res://elements/Exit.tscn"),
    'redkey': preload("res://elements/RedKey.tscn"),
    'bluekey': preload("res://elements/BlueKey.tscn"),
    'greenkey': preload("res://elements/GreenKey.tscn"),
    'yellowkey': preload("res://elements/YellowKey.tscn"),
    'reddoor': preload("res://elements/RedDoor.tscn"),
    'bluedoor': preload("res://elements/BlueDoor.tscn"),
    'greendoor': preload("res://elements/GreenDoor.tscn"),
    'yellowdoor': preload("res://elements/YellowDoor.tscn"),
    'bomb': preload("res://elements/Bomb.tscn"),
    'lava': preload("res://elements/Lava.tscn"),
}

var ALL_LEVEL_SETS = []

var current_file = 0
var current_level_set = '02_sporko'
var current_level_number = 6
var on_exit = 'quit'

var progress


func _ready():
#    var dir = Directory.new()
#    dir.open('res://levels')
#    dir.list_dir_begin()
#    while true:
#        var file = dir.get_next()
#        if file == '':
#            break
#        if file == '.' or file == '..':
#            continue
##        if file == '00_testing':
##            continue
#        ALL_LEVEL_SETS.append(file)
#    dir.list_dir_end()
    ALL_LEVEL_SETS = ['00_testing', '01_tutorial', '02_sporko', '03_nps']
    self.load_progress()
    self.current_level_number = self.progress[self.current_file][self.current_level_set]


func save_progress():
    var save = File.new()
    save.open('user://progress.save', File.WRITE)
    save.store_line(to_json(self.progress))
    save.close()


func load_progress():
    var save = File.new()
    if not save.file_exists('user://progress.save'):
    #if true:
        self.progress = []
        for f in range(4):
            var p = {}
            for i in ALL_LEVEL_SETS:
                p[i] = 1
                #p[i] = 10 if f == 3 else 1
            self.progress.append(p)
        self.save_progress()
    save.open('user://progress.save', File.READ)
    self.progress = parse_json(save.get_line())
    save.close()
    
    
func progress_level():
    if self.progress[self.current_file][self.current_level_set] == self.current_level_number and self.current_level_number < MAX_LEVEL:
        self.progress[self.current_file][self.current_level_set] += 1
        self.save_progress()

#func _process(delta):
#    if Input.is_action_just_pressed("ui_cancel"):
#        if self.on_exit == 'quit':
#            get_tree().quit()
#        elif self.on_exit == 'editor':
#            get_tree().change_scene('res://Editor.tscn')
#
#    # TEMP
#    if Input.is_action_just_pressed("ui_accept"):
#        test_level(self.current_level_set, self.current_level_number+1)


func test_level(level_set, level_number):
    self.current_level_set = level_set
    self.current_level_number = level_number
    get_tree().change_scene('res://Game.tscn')
