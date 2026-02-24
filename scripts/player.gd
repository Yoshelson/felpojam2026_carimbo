extends CharacterBody3D
class_name Player

const SPEED = 5.0
const SENSITIVITY = 0.002

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var seecast = $head/Camera3D/SeeCast

signal focus_changed (new_prompt: String)

#Prender personagem enquanto ele interage
var input_locked:bool = false
var _focused_object: Node3D = null

func _ready() -> void:
	add_to_group("Player")
	#Começa o jogo com o mouse no centro da tela
	#Ps: alterar depois que fizer o menu principal
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return
	
	#Camera no mouse
	if event is  InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(70))
		
	
	#Uso do Seecast para interagir com ambiente apenas nos layers de colisão 3, ou seja o que se dá pra interagir
	if Input.is_action_just_pressed("interact"):
		if !(_focused_object == null):
			_focused_object.interact(self)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if input_locked:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	if seecast.is_colliding():
		var collided: Node3D = seecast.get_collider(0)
		#Ao collidir com objeto contendo "interact", irá utilizar a função de interagir daquele objeto
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
	else:
		_clear_focus()
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

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
		
func _handle_prompt_changed(prompt: String):
	emit_signal("focus_changed", prompt)
