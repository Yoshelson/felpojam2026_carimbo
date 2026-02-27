extends Interactable
class_name SimpleInteractable

var _original_prompt: String

func _ready() -> void:
	_original_prompt = prompt_message

func interact(_interactor: Node3D):
	if (is_interactable):
		is_interactable = false
		_mesh.material_overlay = null
		prompt_message = ""
		GameEvents.subtitle_requested.emit("Monique:", "A encomenda chegou?", 4)
		play_sfx()
		await get_tree().create_timer(4).timeout
		is_interactable = true
		prompt_message = _original_prompt
