extends Node

enum player_states {walking, desk, board, computer, doc_ui, cinematic_ui, monster}
signal player_state_changed(new_state: player_states)

func change_player_state(state: player_states):
	emit_signal("player_state_changed", state)
