extends Node

enum game_states {WALKING, DESK, COMPUTER, DOCUMENT, CUTSCENE}
signal game_state_changed(new_state: game_states)

func toggle_state(state: game_states):
	match state:
		game_states.WALKING:
			emit_signal("game_state_changed", state)
		game_states.DESK:
			emit_signal("game_state_changed", state)
		game_states.COMPUTER:
			emit_signal("game_state_changed", state)
		game_states.DOCUMENT:
			emit_signal("game_state_changed", state)
