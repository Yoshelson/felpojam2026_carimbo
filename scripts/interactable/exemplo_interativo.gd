extends Interactable

var opened := false

func interact(interactor: Node3D):
	if opened:
		close_drawer()
		_prompt_message = "Abrir Gaveta"
	else:
		open_drawer()
		_prompt_message = "Fechar Gaveta"
	
func close_drawer():
	opened = false
	$AnimationPlayer.play("close")

func open_drawer():
	opened = true
	$AnimationPlayer.play("open")
	
func on_focus_entered():
	_mesh.material_overlay = _material_overlay

func on_focus_exited():
	_mesh.material_overlay = null
	
