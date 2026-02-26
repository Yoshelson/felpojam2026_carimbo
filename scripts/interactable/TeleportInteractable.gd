extends Interactable

@export var target_state: GameEvents.player_states
@export var target_pos: Marker3D
var original_prompt: String

func _ready() -> void:
	original_prompt = prompt_message

func interact(interactor: Node3D):
	if is_interactable:
		is_interactable = false
		_mesh.material_overlay = null
		prompt_message = ""
		
		if interactor is Player:
			interactor.teleport_to(target_pos.global_transform)
			GameEvents.change_player_state(target_state)
		
		is_interactable = true
		prompt_message = original_prompt
