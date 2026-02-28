extends SimpleInteractable

var opened := false

func interact(_interactor: Node3D):
	if not is_interactable:
		return
	is_interactable = false
	_mesh.material_overlay = null
	prompt_message = ""
	play_sfx()
	
	if opened:
		$"../../AnimationPlayer".play_backwards("GAVETA-colAction")
	else:
		$"../../AnimationPlayer".play("GAVETA-colAction")
	opened = !opened
	
	GameEvents.subtitle_requested.emit("Você", "gaveta...", 1.5)
	
	is_interactable = true
	
