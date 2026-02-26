extends Camera3D

@export var base_rotation: Vector3 = Vector3(0, 0, 0)
@export var strength: float = 2.5
@export var smoothness: float = 4.0

var target_rotation: Vector3

func _ready():
	base_rotation = rotation_degrees
	target_rotation = base_rotation

func _process(delta):
	var viewport_size = get_viewport().size
	var mouse = get_viewport().get_mouse_position()

	# Normaliza mouse de -1 a 1
	var normalized = Vector2(
		(mouse.x / viewport_size.x) * 2.0 - 1.0,
		(mouse.y / viewport_size.y) * 2.0 - 1.0
	)

	# Mouse horizontal gira no eixo Y, vertical no X (invertido pra ser natural)
	target_rotation = Vector3(
		base_rotation.x + (-normalized.y * strength),
		base_rotation.y + (-normalized.x * strength),
		base_rotation.z
	)

	rotation_degrees = rotation_degrees.lerp(target_rotation, smoothness * delta)
