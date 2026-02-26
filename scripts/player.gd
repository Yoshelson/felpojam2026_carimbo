extends CharacterBody3D
class_name Player

const SPEED = 5.0
const SENSITIVITY = 0.002

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var seecast = $head/Camera3D/SeeCast
signal focus_changed (new_prompt: String)

var _focused_object: Node3D = null

func _ready() -> void:
	add_to_group("Player")	

#Essa funcao rotaciona a cabeca do player com a posicao do mouse, o bool 
#apply_clamp eh usado para travar a ate 180 graus com base no ultimo ponto de 
#travamento da camera
func rotate_camera(relative_x: float, relative_y: float, apply_clamp: bool = false):
	camera.rotate_x(relative_y * SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(70))
	
	head.rotate_y(relative_x * SENSITIVITY)
	
	#Consideramos que a ancora é sempre a posição atual da camera, logo, 90 graus
	#para cada lado partindo dela. Caso queiramos algo movel no futuro, devera ter
	#uma ancora antes da soma ou subtracao com os "degree"
	if apply_clamp:
		var limite_min = -deg_to_rad(90)
		var limite_max = deg_to_rad(90)
		head.rotation.y = clamp(head.rotation.y, limite_min, limite_max)

func teleport_to(target_transform: Transform3D):
	#Garante que nenhuma movimentacao errada ocorra apos o teleporte
	velocity = Vector3.ZERO
	self.global_position = target_transform.origin
	
	var euler = target_transform.basis.get_euler()
	#Movemos a entidade player inteira para a posicao desejada e depois resetamos
	#a camera(cabeca) para ficar alinhada com a rotacao pretendida
	self.global_rotation.y = euler.y
	head.rotation.y = 0
	head.rotation.z = 0.0
	#Coloca a variavel de rotacao X da camera (a unica da camera que se move em
	#rotate camera para a posicao desejada e depois resetamos para alinhar com a 
	#rotacao pretendida
	camera.global_rotation.x = euler.x
	camera.global_rotation.z = 0.0

func teleport_camera_to(target_transform: Transform3D) -> void:
	camera.global_transform = target_transform

func reset_camera_pos() -> void:
	camera.transform = Transform3D.IDENTITY

func try_interact():
	if !(_focused_object == null):
		_focused_object.interact(self)

func get_mouse_hit_node() -> Node3D:
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	
	var origin = camera.project_ray_origin(mouse_position)
	var end = camera.project_ray_normal(mouse_position) * 50
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 4 #Layer dos colliders
	
	var result = space_state.intersect_ray(query)
	
	if result:
		if result.collider:
			#garantindo a tipagem para evitar bugs esquisitos
			return result.collider as Node3D 
	return null

func get_seecast_hit_node() -> Node3D:
	if seecast.is_colliding():
		return seecast.get_collider(0)
	return null

func update_focus(collided: Node3D):
	if (collided is Interactable) and (collided.is_interactable):
		if (_focused_object == collided):
			pass
		elif (_focused_object == null):
			_new_focus(collided)
		else:
			_focused_object.on_focus_exited()
			_new_focus(collided)
	else:
		_clear_focus()

func _new_focus(focus_obj : Node3D):
	_focused_object = focus_obj
	_focused_object.on_focus_entered()
	_focused_object.prompt_changed.connect(_handle_prompt_changed)
	emit_signal("focus_changed", _focused_object.prompt_message)

func _clear_focus():
	if !(_focused_object == null):
		if _focused_object.prompt_changed.is_connected(_handle_prompt_changed):
			_focused_object.prompt_changed.disconnect(_handle_prompt_changed)
			
		_focused_object.on_focus_exited()
		_focused_object = null
		emit_signal("focus_changed", "")

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
func apply_movement(input_dir: Vector2):
	var direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()

func _handle_prompt_changed(prompt: String):
	emit_signal("focus_changed", prompt)
