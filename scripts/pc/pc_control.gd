extends Control
class_name PCControl

@onready var window_layer: Control = $Desktop_Root/WindowLayer
@onready var taskbar_app_list: HBoxContainer = $Desktop_Root/Taskbar/AppContainer
@onready var mouse_cursor: Sprite2D = $Mouse
@onready var login_screen: Control = $Login
@onready var exit_button: Button = $Desktop_Test/Quit
@onready var desktop_root: Control = $Desktop_Root
@onready var desktop_bg: TextureRect = $Desktop_Root/Desktop_BG

signal exit_requested

var pc_mouse_pos: Vector2 = Vector2.ZERO
var open_windows: Dictionary = {}

const CASCADE_OFFSET := Vector2(26, 26)
const CASCADE_START  := Vector2(60, 40)
const CASCADE_MAX_X  := 1100.0
const CASCADE_MAX_Y  := 800.0
var cascade_pos := CASCADE_START

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
	if window.get_parent():
		window.get_parent().move_child(window, -1)
	if window.has_meta("taskbar_button"):
		var btn = window.get_meta("taskbar_button")
		if btn:
			btn.button_pressed = true

func open_window(scene: PackedScene, app_name: String, spawn_pos := Vector2.ZERO):
	if open_windows.has(app_name):
		var existing = open_windows[app_name]
		if existing.is_minimized:
			existing.restore()
			request_focus(existing)
			return
		existing.queue_free()
		return

	var window = scene.instantiate()
	window_layer.add_child(window)
	window.set_title(app_name)
	window.minimized.connect(_on_window_minimized)
	window.tree_exited.connect(_on_window_closed.bind(app_name))
	open_windows[app_name] = window

	if spawn_pos != Vector2.ZERO:
		window.position = spawn_pos
	else:
		window.position = cascade_pos
		_advance_cascade()

	_add_taskbar_button(window, app_name)
	request_focus(window)

func _advance_cascade():
	cascade_pos += CASCADE_OFFSET
	if cascade_pos.x > CASCADE_MAX_X or cascade_pos.y > CASCADE_MAX_Y:
		cascade_pos = CASCADE_START

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

func _add_taskbar_button(window: WindowBase, app_name: String):
	var btn = Button.new()
	btn.toggle_mode = true
	btn.button_pressed = true
	btn.flat = true
	btn.custom_minimum_size = Vector2(72, 72)

	if window.window_icon:
		btn.icon = window.window_icon
		btn.expand_icon = true
	else:
		var parts = app_name.split(" ")
		var initials = ""
		for p in parts:
			if p.length() > 0:
				initials += p[0].to_upper()
		btn.text = initials.left(2)

	btn.pressed.connect(func():
		if window.is_minimized:
			window.restore()
		request_focus(window)
	)
	window.set_meta("taskbar_button", btn)
	taskbar_app_list.add_child(btn)

func show_alert(message: String, spawn_pos := Vector2.ZERO):
	var scene = preload("res://scenes/interactables/computer/alert_window.tscn")
	var alert = scene.instantiate()
	window_layer.add_child(alert)
	alert.set_title("Sistema")
	alert.set_message(message)

	if spawn_pos != Vector2.ZERO:
		alert.position = spawn_pos
	else:
		await get_tree().process_frame
		var viewport_size = get_viewport_rect().size
		alert.position = (viewport_size - alert.size) / 2.0

	request_focus(alert)

func install_toque_dourado_delayed(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	show_alert("Toque Dourado foi instalado com sucesso.")
	spawn_new_desktop_file(
		"Toque Dourado",
		preload("res://scenes/interactables/computer/toque_dourado_app.tscn")
	)
	spawn_new_desktop_file(
		"Messenger",
		preload("res://scenes/interactables/computer/messager.tscn"),
		true,
		Vector2(820, 660)
	)

func spawn_new_desktop_file(
	app_name: String,
	scene: PackedScene,
	hide_by_gold := false,
	custom_position := Vector2.ZERO
) -> void:
	var icon_scene = preload("res://scenes/interactables/computer/desktop_app_icons.tscn")
	var icon = icon_scene.instantiate() as DesktopAppIcon

	if custom_position != Vector2.ZERO:
		desktop_bg.add_child(icon)
		icon.position = custom_position
		icon.custom_minimum_size = Vector2(96, 110)
		icon.size = Vector2(96, 110)
	else:
		$Desktop_Root/Desktop_Icons.add_child(icon)

	icon.setup(
		scene,
		app_name,
		preload("res://arts/test/midastoque_test.png")
	)

	if hide_by_gold:
		icon.hide_by_gold()
