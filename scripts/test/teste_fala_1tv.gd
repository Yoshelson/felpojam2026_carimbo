extends SimpleInteractable

func interact(_interactor: Node3D):
	if not is_interactable:
		return
	is_interactable = false
	_mesh.material_overlay = null
	prompt_message = ""
	play_sfx()
	
	GameEvents.subtitle_requested.emit("Monique:", "Essa [wave]coisa[/wave] nem tem o que transmitir de bom.", 3.5)
	
	await get_tree().create_timer(3.5).timeout
	is_interactable = true
	prompt_message = _original_prompt
