extends CollisionObject3D
class_name Interactable

@export var _id: String = ""
@export var _mesh: Node3D = null
@export var is_interactable = true
@export var prompt_message: String:
	set (value):
		prompt_message = value
		emit_signal("prompt_changed", prompt_message)

@export var audio_player: AudioStreamPlayer3D
@export var sfx_audio: AudioStream

@onready var _material_overlay = preload("res://scripts/shaders/test/highlight_test.tres")

signal prompt_changed(new_prompt: String)

func interact(_interactor: Node3D):
	push_warning("Método interact() não implementado em: ", name)

func on_focus_entered():
	if (is_interactable):
		_mesh.material_overlay = _material_overlay

func on_focus_exited():
	_mesh.material_overlay = null
	
func play_sfx():
	if sfx_audio and audio_player:
		audio_player.stream = sfx_audio
		audio_player.play()
