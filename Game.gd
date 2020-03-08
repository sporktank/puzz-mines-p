extends Node2D


func _ready():
    $Level.load_from_file(Global.current_level_set, Global.current_level_number)
    $Level.set_play_mode()
    $HUD/LevelSetAndNumber.text = $Level.level_set.substr(3,99).to_upper() + ' ' + str($Level.level_number)
    $HUD/LevelName.text = $Level.level_name
    $HUD/Previous.disabled = Global.current_level_number == 1
    $HUD/Next.disabled = Global.current_level_number == Global.progress[Global.current_file][Global.current_level_set]
    
    
func _process(delta):
    
    $FPS.text = 'FPS: ' + str(Engine.get_frames_per_second())
    #$FPS.text = '%s | %s | %s | %s' % [
    #        Engine.get_frames_drawn(),
    #        Engine.get_frames_per_second(),
    #        1,
    #        1
    #    ]
    
    #$HUD/Required.text = "coins: %d / %d" % [$Level.coins_collected, $Level.coins_required]
    $HUD/CoinCount.text = "%d / %d" % [$Level.coins_collected, $Level.coins_required]
    $HUD/BombCount.text = str($Level.player_ref.bomb_count)
    $HUD/RedKey.modulate.a = 1.0 if $Level.player_ref.has_collected_key['red'] else 0.1
    $HUD/BlueKey.modulate.a = 1.0 if $Level.player_ref.has_collected_key['blue'] else 0.1
    $HUD/GreenKey.modulate.a = 1.0 if $Level.player_ref.has_collected_key['green'] else 0.1
    $HUD/YellowKey.modulate.a = 1.0 if $Level.player_ref.has_collected_key['yellow'] else 0.1
    
    $HUD/Previous.disabled = Global.current_level_number == 1
    $HUD/Next.disabled = Global.current_level_number == Global.progress[Global.current_file][Global.current_level_set] or Global.current_level_number == Global.MAX_LEVEL
    
    if Input.is_action_just_pressed("restart"):
        _on_Restart_pressed()
        
    if Input.is_action_just_pressed("previous") and not $HUD/Previous.disabled:
        _on_Previous_pressed()
        
    if Input.is_action_just_pressed("next") and not $HUD/Next.disabled:
        _on_Next_pressed()
        
    if Input.is_action_just_pressed("exit"):
        _on_Exit_pressed()
        

func _on_Restart_pressed():
    #$Level.restart()
    Global.test_level(Global.current_level_set, Global.current_level_number)


func _on_HowToPlayButton_pressed():
    $HUD/HowToPlay.visible = not $HUD/HowToPlay.visible


func _on_Exit_pressed():
    if Global.on_exit == 'editor':
        get_tree().change_scene('res://Editor.tscn')
    elif Global.on_exit == 'menu':
        get_tree().change_scene('res://Menu.tscn')
    else:
        get_tree().quit()


func _on_Previous_pressed():
    if Global.current_level_number > 1:
        #$Level.load_from_file(Global.current_level_set, Global.current_level_number-1)
        Global.test_level(Global.current_level_set, Global.current_level_number-1)


func _on_Next_pressed():
    if Global.current_level_number < 10:
        #$Level.load_from_file(Global.current_level_set, Global.current_level_number+1)
        #Global.current_level_number += 1
        #$Level.restart()
        Global.test_level(Global.current_level_set, Global.current_level_number+1)
