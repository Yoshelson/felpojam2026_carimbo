extends Control
class_name PCControl

@onready var mouse_cursor: Sprite2D = $Mouse
var pc_mouse_pos:Vector2 = Vector2.ZERO

signal exit_requested

@onready var exit_button: Button = $Quit
var player:Player

# Called when the node enters the scene tree for the first time.
func _ready():
	exit_button.pressed.connect(_on_exit_pressed)

func _on_exit_pressed():
	emit_signal("exit_requested")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_cursor_pos():
	mouse_cursor.position = pc_mouse_pos
