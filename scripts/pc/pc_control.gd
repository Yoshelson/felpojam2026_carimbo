extends Control
class_name PCControl

@onready var window_layer: Control = $Desktop_Root/WindowLayer
@onready var taskbar_app_list: HBoxContainer = $Desktop_Root/Taskbar/AppContainer
@onready var mouse_cursor: Sprite2D = $Mouse
@onready var login_screen: Control = $LoginScreen
@onready var exit_button: Button = $Desktop_Test/Quit

signal exit_requested

var pc_mouse_pos: Vector2 = Vector2.ZERO
var top_z := 1
var open_windows: Dictionary = {}

func _ready():
	add_to_group("pc_control")
	exit_button.pressed.connect(_on_exit_pressed)
	login_screen.login_success.connect(_on_login_success)

func _on_login_success():
	print("Login realizado")

func _on_exit_pressed():
	emit_signal("exit_requested")

func update_cursor_pos():
	mouse_cursor.position = pc_mouse_pos

func request_focus(window: Control):
	top_z += 1
	window.z_index = top_z
	
	var btn = window.get_meta("taskbar_button")
	if btn:
		btn.button_pressed = true

func open_window(scene: PackedScene, app_name: String):

	if open_windows.has(app_name):
		var existing = open_windows[app_name]
		
		if existing.is_minimized:
			existing.restore()
			request_focus(existing)
			return
		
		# Se já está aberto, fecha
		existing.queue_free()
		return

	# Criar nova
	var window = scene.instantiate()
	window_layer.add_child(window)
	window.set_title(app_name)

	window.minimized.connect(_on_window_minimized)
	window.tree_exited.connect(_on_window_closed.bind(app_name))

	open_windows[app_name] = window
	
	_add_taskbar_button(window)
	request_focus(window)

func _on_window_minimized(window):
	var btn = window.get_meta("taskbar_button")
	if btn:
		btn.button_pressed = false

func _on_window_closed(app_name: String):
	if not open_windows.has(app_name):
		return
	
	var window = open_windows[app_name]
	var btn = window.get_meta("taskbar_button")
	
	if btn:
		btn.queue_free()
	
	open_windows.erase(app_name)

func _add_taskbar_button(window: WindowBase):
	var btn = Button.new()
	btn.toggle_mode = true
	btn.button_pressed = true
	btn.flat = true
	btn.custom_minimum_size = Vector2(48,48)

	if window.window_icon:
		btn.icon = window.window_icon
		btn.expand_icon = true

	btn.pressed.connect(func():
		if window.is_minimized:
			window.restore()
		else:
			request_focus(window)
	)

	window.set_meta("taskbar_button", btn)
	taskbar_app_list.add_child(btn)
