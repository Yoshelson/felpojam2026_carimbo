extends State

func enter_state():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player._clear_focus()
	player.velocity = Vector3.ZERO
	print(player.velocity)

func inputs(_event: InputEvent):
	pass

func physics_update(_delta: float):
	player.velocity = Vector3.ZERO
	player.move_and_slide()
