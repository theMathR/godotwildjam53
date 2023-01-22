extends PanelContainer

func _on_Unpause_pressed():
	hide()
	$"../Drums".play(Music.time)
	get_tree().paused = false
	$"../Click".play()


func _on_Retry_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_Main_screen_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")
	get_tree().paused = false
