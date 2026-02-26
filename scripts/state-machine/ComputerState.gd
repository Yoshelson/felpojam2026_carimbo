extends State

#Potencial gambiarra para funcionamento, verificar escalabilidade com cuidado
#depois do termino da gamejam
@export var computer: PCStatic

func enter_state():
	pass

func exit_state():
	player.reset_camera_pos()
	
func inputs(event: InputEvent):
	if event is InputEventKey:
		if Input.is_action_just_pressed("exit"):
			GameEvents.change_player_state(GameEvents.player_states.desk)
		else:
			computer.handle_key_press(event)
	
	elif event is InputEventMouseButton:
		computer.handle_mouse_btn_press(event)
	
	#Move o mouse na tela
	elif event is InputEventMouseMotion:
		computer.handle_mouse_mov(event)
	
func physics_update(delta: float):
	player.apply_gravity(delta)

	#pc_control.exit_requested.connect(toggle_use)
