extends Node2D


func _ready():
    $Level.load_from_file()
    $Level.set_play_mode()
    
    
func _process(delta):
    if Input.is_action_pressed("ui_cancel"):
        get_tree().quit()
        
    $HUD/Required.text = "coins: %d / %d" % [$Level.coins_collected, $Level.coins_required]
        

func _on_Restart_pressed():
    $Level.restart()
