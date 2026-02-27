extends State

func enter_state():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.set_interaction_layers(true, false, false)

func exit_state():
	pass
	
func inputs(event: InputEvent):
	if event is InputEventMouseMotion:
		player.rotate_camera(-event.relative.x, -event.relative.y)
	
	if Input.is_action_just_pressed("interact"):
		player.try_interact()
	
func physics_update(delta: float):
	player.apply_gravity(delta)
	
	var collided: Node3D = player.get_seecast_hit_node()
	#adicionar verificacao de estado aqui e repassa null caso nao deva interagir
	player.update_focus(collided)
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	player.apply_movement(input_dir)
	player.sound_steps(delta)
