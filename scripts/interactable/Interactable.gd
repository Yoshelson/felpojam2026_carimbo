extends CollisionObject3D
class_name Interactable

@export var _id: String = ""
@export var _mesh: Node3D = null
@export var is_interactable = true
@export var prompt_message: String:
	set (value):
		prompt_message = value
		emit_signal("prompt_changed", prompt_message)
@onready var _material_overlay = preload("res://scripts/shaders/test/highlight_test.tres")

signal prompt_changed(new_prompt: String)

func interact(interactor: Node3D):
	push_warning("Método interact() não implementado em: ", name)

func on_focus_entered():
	pass

func on_focus_exited():
	pass
