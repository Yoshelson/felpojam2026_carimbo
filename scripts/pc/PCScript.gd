extends TeleportInteractable
class_name PCStatic

@onready var screen_material: ShaderMaterial = $PCScreenMesh.material_override

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
	if event.button_index == MOUSE_BUTTON_LEFT or MOUSE_BUTTON_WHEEL_DOWN or MOUSE_BUTTON_WHEEL_UP:
		var mouse_event = InputEventMouseButton.new()
		mouse_event.button_index = event.button_index
		mouse_event.pressed = event.pressed
		mouse_event.double_click = event.double_click
		mouse_event.position = pc_control.pc_mouse_pos
		mouse_event.global_position = pc_control.pc_mouse_pos
		sub_viewport.push_input(mouse_event)

func handle_key_press(event: InputEventKey) :
	sub_viewport.push_input(event)
