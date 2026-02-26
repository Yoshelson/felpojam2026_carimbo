extends State
#Potencial gambiarra para funcionamento, verificar escalabilidade com cuidado
#depois do termino da gamejam
@export var desk_pos: Marker3D
@export var walk_pos: Marker3D

func enter_state():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.teleport_to(desk_pos.global_transform)

func exit_state():
	player.teleport_to(walk_pos.global_transform)
	
func inputs(event: InputEvent):
	if event is InputEventKey:
		if Input.is_action_just_pressed("exit"):
			GameEvents.change_player_state(GameEvents.player_states.walking)
	
	if event is InputEventMouseMotion:
		player.rotate_camera(-event.relative.x, -event.relative.y, true)
	
	if Input.is_action_just_pressed("interact"):
		player.try_interact()
	
func physics_update(delta: float):
	player.apply_gravity(delta)
	
	var collided: Node3D = player.get_seecast_hit_node()
	#adicionar verificacao de estado aqui e repassa null caso nao deva interagir
	player.update_focus(collided)
