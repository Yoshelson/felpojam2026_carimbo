extends State

func enter_state():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_interaction_layers(false, false, true)

func exit_state():
	pass
	
func inputs(event: InputEvent):	
	if event is InputEventKey:
		if Input.is_action_just_pressed("exit"):
			GameEvents.change_player_state(GameEvents.player_states.desk)
			player.reset_camera_pos()
	if Input.is_action_just_pressed("interact"):
		player.try_interact()
	
func physics_update(delta: float):
	player.apply_gravity(delta)
	
	var collided: Node3D = player.get_mouse_hit_node()
	#adicionar verificacao de estado aqui e repassa null caso nao deva interagir
	player.update_focus(collided)
