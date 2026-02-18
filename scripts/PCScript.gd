extends StaticBody3D
class_name PCStatic

@onready var screen_material: ShaderMaterial = $PCScreenMesh.material_override

#Animação de ligar o pc pela primeira vez
var boot_played := false

var player:Player
var is_using:bool = false
@onready var camera_3d: Camera3D = $Camera3D
@onready var pc_control: Control = $SubViewport/PCControl
@onready var sub_viewport: SubViewport = $SubViewport

func interact(_player_ref: Player):
	toggle_use()

func play_boot_effect():
	if boot_played:
		return
	
	boot_played = true
	
	screen_material.set_shader_parameter("power_on", 0.0)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_method(
		func(value):
			screen_material.set_shader_parameter("power_on", value),
		0.0,
		1.0,
		1.6  
	)

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	print("Player")
	pc_control.exit_requested.connect(toggle_use)

#Função de começar a usar o pc
func toggle_use():
	is_using = !is_using
	camera_3d.current = is_using
	player.camera.current = !is_using
	player.input_locked = is_using
	player.seecast.enabled = !is_using
	
	if is_using:
		play_boot_effect()
	

func _input(event: InputEvent) -> void:
	if !is_using:
		return
	
	if player == null:
		return
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("exit"):
			toggle_use()
			
		else:
			sub_viewport.push_input(event)
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_event = InputEventMouseButton.new()
			mouse_event.button_index = event.button_index
			mouse_event.pressed = event.pressed
			mouse_event.position = pc_control.pc_mouse_pos
			mouse_event.global_position = pc_control.pc_mouse_pos
			sub_viewport.push_input(mouse_event)
	
	#Move o mouse na tela
	elif event is InputEventMouseMotion:
		pc_control.pc_mouse_pos += event.relative
		pc_control.pc_mouse_pos.x = clamp(pc_control.pc_mouse_pos.x, 0.0, sub_viewport.size.x - 10.0)
		pc_control.pc_mouse_pos.y = clamp(pc_control.pc_mouse_pos.y, 0.0, sub_viewport.size.y - 10.0)
		pc_control.update_cursor_pos()
		
