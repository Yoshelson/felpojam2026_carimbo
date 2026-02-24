extends Interactable

var opened := false

func interact(_interactor: Node3D):
	if (is_interactable):
		#Impedindo o efeito visual de brilho no momento da animacao
		is_interactable = false
		_mesh.material_overlay = null
		prompt_message = ""
		if opened:
			$AnimationPlayer.play("close")
		else:
			$AnimationPlayer.play("open")
		opened = !opened
		
		await $AnimationPlayer.animation_finished
		
		#Reativando efeitos depois da animacao acabar
		is_interactable = true
		if opened:
			prompt_message = "Fechar Gaveta"
		else:
			prompt_message = "Abrir Gaveta"
