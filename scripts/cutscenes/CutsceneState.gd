extends State

func enter_state():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player._clear_focus()

func inputs(_event: InputEvent):
	pass

func physics_update(_delta: float):
	pass
