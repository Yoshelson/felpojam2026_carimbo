extends CharacterBody3D
class_name Player


const SPEED = 5.0
const SENSITIVITY = 0.002

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var seecast = $head/Camera3D/SeeCast

#Prender personagem enquanto ele interage
var input_locked:bool = false

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
		if seecast.is_colliding():
			var collided = seecast.get_collision_result()[0]["collider"]
			print(collided)
			if collided is PCStatic:
				collided.toggle_use()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if input_locked:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
