extends CanvasLayer

@export var parallax_strength: float = 8.0
@export var smoothness: float = 6.0

var target_offset: Vector2 = Vector2.ZERO

@onready var panel: Control = $Menu

func _process(delta):
	var viewport_size = get_viewport().size
	var mouse = get_viewport().get_mouse_position()

	var normalized = Vector2(
		(mouse.x / viewport_size.x) * 2.0 - 1.0,
		(mouse.y / viewport_size.y) * 2.0 - 1.0
	)

	target_offset = normalized * parallax_strength

	panel.position = panel.position.lerp(
		Vector2(viewport_size / 2.0) - panel.size / 2.0 + target_offset,
		smoothness * delta
	)
