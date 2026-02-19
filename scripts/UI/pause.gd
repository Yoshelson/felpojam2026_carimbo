extends Control


func _ready():
	hide()
	$AnimationPlayer.play("RESET")
	$"PanelContainer/settings_menu/settings_tab/Gráficos/fullscreen".button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else false
	$PanelContainer/settings_menu/settings_tab/Sons/volMaster.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$PanelContainer/settings_menu/settings_tab/Sons/volMusic.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MUSIC")))
	$PanelContainer/settings_menu/settings_tab/Sons/volSfx.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PanelContainer/pause_menu.visible = true
	$PanelContainer/settings_menu.visible = false
	hide()

func pause():
	get_tree().paused = true
	print("pausou")
	$AnimationPlayer.play("blur")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _process(_delta):
	testEsc()
	

func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	get_tree().quit()


func _on_configurations_pressed():
	$PanelContainer/pause_menu.visible = false
	$PanelContainer/settings_menu.visible = true


func _on_back_pressed() -> void:
	$PanelContainer/pause_menu.visible = true
	$PanelContainer/settings_menu.visible = false



# Opções de gráficos
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)




func _on_vol_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_vol_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("MUSIC"), value)

func _on_vol_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
