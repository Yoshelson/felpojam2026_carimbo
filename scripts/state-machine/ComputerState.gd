extends State

@export var computer: PCStatic

func enter_state():
	pass

func exit_state():
	player.reset_camera_pos()

func inputs(event: InputEvent):
	if event is InputEventKey:
		var typing = computer.pc_control.is_typing()
		
		
		if typing:
			computer.handle_key_press(event)
			return
		
		if event.is_action_pressed("exit"):
			GameEvents.change_player_state(GameEvents.player_states.desk)
		else:
			computer.handle_key_press(event)
	
	elif event is InputEventMouseButton:
		computer.handle_mouse_btn_press(event)
	
	elif event is InputEventMouseMotion:
		computer.handle_mouse_mov(event)

func physics_update(delta: float):
	player.apply_gravity(delta)
