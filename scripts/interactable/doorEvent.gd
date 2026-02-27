extends SimpleInteractable

func interact(_interactor: Node3D):
	if not is_interactable:
		return
	is_interactable = false
	_mesh.material_overlay = null
	prompt_message = ""
	play_sfx()
	
	GameEvents.change_player_state(GameEvents.player_states.cinematic_ui)
	GameEvents.subtitle_requested.emit("Você", "Eu não me lembro de pedir algo.", 2.5)
	
	await get_tree().create_timer(2.5).timeout
	
	$AnimationPlayer.play("door_open")
	
	await $AnimationPlayer.animation_finished
	
	GameEvents.change_player_state(GameEvents.player_states.walking)
	is_interactable = true
	prompt_message = _original_prompt
