extends Interactable
class_name TeleportInteractable

@export var target_state: GameEvents.player_states
@export var camera_target_pos: Marker3D
var original_prompt: String

func _ready() -> void:
	original_prompt = prompt_message

func interact(interactor: Node3D):
	if is_interactable:
		is_interactable = false
		_mesh.material_overlay = null
		prompt_message = ""
		
		if interactor is Player:
			GameEvents.change_player_state(target_state)
			interactor.teleport_camera_to(camera_target_pos.global_transform)
		
		is_interactable = true
		prompt_message = original_prompt
