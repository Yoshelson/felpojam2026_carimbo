extends TeleportInteractable
class_name PCStatic

@onready var screen_material: ShaderMaterial = $PCScreenMesh.material_override

@onready var click_players: Array = [
	$ClickSFX1, $ClickSFX2, $ClickSFX3
	]
var _click_idx: int = 0

func _on_mouse_click():
	var player = click_players[_click_idx]
	player.play()
	_click_idx = (_click_idx + 1) % click_players.size()

#Animação de ligar o pc pela primeira vez
var boot_played := false

@onready var pc_control: Control = $SubViewport/ViewportRoot/PCControl
@onready var sub_viewport: SubViewport = $SubViewport

func interact(_interactor: Node3D):
	super.interact(_interactor)
	play_boot_effect()

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
	pass

func handle_mouse_mov(event: InputEventMouseMotion) :
	# Bloqueia movimento do mouse enquanto um diálogo prioritário estiver ativo
	var subtitle_ui = get_tree().get_first_node_in_group("subtitle_ui")
	if subtitle_ui and subtitle_ui.is_processing_input():
		return
	
	pc_control.pc_mouse_pos += event.relative
	pc_control.pc_mouse_pos.x = clamp(pc_control.pc_mouse_pos.x, 0.0, sub_viewport.size.x - 10.0)
	pc_control.pc_mouse_pos.y = clamp(pc_control.pc_mouse_pos.y, 0.0, sub_viewport.size.y - 10.0)
	pc_control.update_cursor_pos()
	
	var motion_event = InputEventMouseMotion.new()
	
	motion_event.position = pc_control.pc_mouse_pos
	motion_event.global_position = pc_control.pc_mouse_pos
	motion_event.button_mask = Input.get_mouse_button_mask()
	motion_event.relative = event.relative
	
	sub_viewport.push_input(motion_event)

func handle_mouse_btn_press(event: InputEventMouseButton):
	var subtitle_ui = get_tree().get_first_node_in_group("subtitle_ui")
	if subtitle_ui and subtitle_ui._waiting_click:
		return

	if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP:
		var mouse_event = InputEventMouseButton.new()
		mouse_event.button_index = event.button_index
		mouse_event.pressed = event.pressed
		mouse_event.double_click = event.double_click
		mouse_event.position = pc_control.pc_mouse_pos
		mouse_event.global_position = pc_control.pc_mouse_pos
		sub_viewport.push_input(mouse_event)
		
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_mouse_click()

func handle_key_press(event: InputEventKey) :
	sub_viewport.push_input(event)
