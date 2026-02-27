extends Interactable
class_name SimpleInteractable

var _original_prompt: String
@export var subtitle_dur: int = 4

func _ready() -> void:
	_original_prompt = prompt_message

func interact(_interactor: Node3D):
	if (is_interactable):
		
		is_interactable = false
		_mesh.material_overlay = null
		prompt_message = ""
		
		GameEvents.subtitle_requested.emit("Monique:", "A encomenda chegou?", subtitle_dur)
		play_sfx()
		await get_tree().create_timer(subtitle_dur).timeout
		
		is_interactable = true
		prompt_message = _original_prompt
