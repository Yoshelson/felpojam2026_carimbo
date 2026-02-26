extends State

@export var hide_mouse: bool = false

func enter_state():
	if hide_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func inputs(event: InputEvent):
	if event is InputEventKey:
		if Input.is_action_just_pressed("exit"):
			GameEvents.change_player_state(GameEvents.player_states.board)
