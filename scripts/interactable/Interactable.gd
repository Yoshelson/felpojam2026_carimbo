extends CollisionObject3D
class_name Interactable

@export var _id: String = ""
@export var _mesh: Node3D = null
@export var _prompt_message: String = ""
@onready var _material_overlay = preload("res://scripts/shaders/test/highlight_test.tres")

func interact(interactor: Node3D):
	push_warning("Método interact() não implementado em: ", name)

func on_focus_entered():
	pass

func on_focus_exited():
	pass
