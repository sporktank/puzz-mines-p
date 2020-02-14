extends Node


const TILE_SIZE = 50


const ALL_ELEMENTS = {
    'player': preload("res://elements/Player.tscn"),
    'blank': preload("res://elements/Blank.tscn"),
    'grass': preload("res://elements/Grass.tscn"),
    'steel': preload("res://elements/Steel.tscn"),
    'rock': preload("res://elements/Rock.tscn"),
    'goldcoin': preload("res://elements/GoldCoin.tscn"),
    'ladybug': preload("res://elements/LadyBug.tscn"),
}


var ALL_LEVELS
