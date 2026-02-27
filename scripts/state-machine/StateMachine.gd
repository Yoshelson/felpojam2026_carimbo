extends Node

var states: Dictionary = {}
@export var initial_state: State
var _player: Player
var _actual_state: State

func start_machine(player: Player) -> void:
	_player = player
	GameEvents.player_state_changed.connect(_on_state_change)
	var state_nodes = self.get_children()
	for state in state_nodes:
		if state is State:
			states[state.id] = state
			state.player = _player
	
	_actual_state = initial_state
	_actual_state.enter_state()

func _process(delta: float) -> void:
	_actual_state.update(delta)
	
func _physics_process(delta: float) -> void:
	_actual_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	_actual_state.inputs(event)

func _on_state_change(state_id: GameEvents.player_states):
	if (states.has(state_id)):
		_actual_state.exit_state()
		_actual_state = states[state_id]
		_actual_state.enter_state()
	else:
		push_error("ERROR: Tentativa de entrar em estado não existente na maquina
		de estados. State ID: ", state_id)
