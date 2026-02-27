extends SimpleInteractable

func interact(_interactor: Node3D):
	if not is_interactable:
		return
	is_interactable = false
	_mesh.material_overlay = null
	prompt_message = ""
	play_sfx()
	
	GameEvents.subtitle_requested.emit("Você", "Que caixa grande.", 1.5)
	await get_tree().create_timer(2.5).timeout
	GameEvents.subtitle_requested.emit("Você", "'Você tem tudo o que precisa aqui'.", 2.5)
	$"../PCScene".set_visible(true)
	
	queue_free()
