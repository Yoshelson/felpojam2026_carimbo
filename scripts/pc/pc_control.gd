extends Control
class_name PCControl

@onready var window_layer: Control = $Desktop_Root/WindowLayer
@onready var taskbar_app_list: HBoxContainer = $Desktop_Root/Taskbar/AppContainer
@onready var mouse_cursor: Sprite2D = $Mouse
@onready var login_screen: Control = $Login
@onready var exit_button: Button = $Desktop_Test/Quit
@onready var desktop_root: Control = $Desktop_Root

signal exit_requested

var pc_mouse_pos: Vector2 = Vector2.ZERO
var open_windows: Dictionary = {}
var loose_icon_layer: Control
var blocking_layer: Control
var glitch_overlay: ColorRect
var login_active: bool = true

const CASCADE_OFFSET := Vector2(26, 26)
const CASCADE_START  := Vector2(60, 40)
const CASCADE_MAX_X  := 1100.0
const CASCADE_MAX_Y  := 800.0
var cascade_pos := CASCADE_START

func is_typing() -> bool:
	# pc_control roda dentro do SubViewport, entao get_viewport() ja retorna
	# o SubViewport correto — nao o viewport principal do jogo
	var focused = get_viewport().gui_get_focus_owner()
	return focused is LineEdit and focused.is_visible_in_tree()

func _ready():
	add_to_group("pc_control")
	exit_button.pressed.connect(_on_exit_pressed)
	login_screen.login_success.connect(_on_login_success)

	loose_icon_layer = Control.new()
	loose_icon_layer.name = "LooseIconLayer"
	loose_icon_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	loose_icon_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop_root.add_child(loose_icon_layer)
	desktop_root.move_child(loose_icon_layer, window_layer.get_index())

	blocking_layer = Control.new()
	blocking_layer.name = "BlockingLayer"
	blocking_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocking_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	blocking_layer.visible = false
	blocking_layer.z_index = 50
	add_child(blocking_layer)

	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.6)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blocking_layer.add_child(dim)

	var hint = Label.new()
	hint.text = "[ sem sinal ]"
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.18))
	hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hint.offset_left = -160
	hint.offset_top = -80
	hint.offset_right = -16
	hint.offset_bottom = -16
	blocking_layer.add_child(hint)

	glitch_overlay = ColorRect.new()
	glitch_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	glitch_overlay.color = Color(1, 1, 1, 0)
	glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glitch_overlay.z_index = 99
	add_child(glitch_overlay)

	spawn_new_desktop_file(
		"Lixo",
		preload("res://scenes/interactables/computer/lixo.tscn"),
		false,
		Vector2(1420, 940),
		preload("res://arts/images/PC/lixo.png")
	)

func play_glitch() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var vp = get_viewport_rect().size

	var artifact_layer = Control.new()
	artifact_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	artifact_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artifact_layer.z_index = 98
	add_child(artifact_layer)

	var spawn_artifacts = func():
		for child in artifact_layer.get_children():
			child.queue_free()

		for i in range(rng.randi_range(4, 10)):
			var bar = ColorRect.new()
			var h = rng.randi_range(4, 28)
			var y = rng.randi_range(0, int(vp.y) - h)
			bar.position = Vector2(0, y)
			bar.size = Vector2(vp.x, h)
			var r = rng.randf_range(0.0, 0.3)
			var g = rng.randf_range(0.0, 0.3)
			var b = rng.randf_range(0.0, 0.3)
			bar.color = Color(r, g, b, rng.randf_range(0.5, 0.9))
			artifact_layer.add_child(bar)

		for i in range(rng.randi_range(3, 7)):
			var frag = ColorRect.new()
			var fw = rng.randi_range(40, 300)
			var fh = rng.randi_range(2, 14)
			frag.position = Vector2(rng.randi_range(0, int(vp.x) - fw), rng.randi_range(0, int(vp.y)))
			frag.size = Vector2(fw, fh)
			var colors = [Color(0.0, 0.0, 1.0, 0.6), Color(0,1,1,0.5), Color(1,1,1,0.4), Color(0,0,0,0.8)]
			frag.color = colors[rng.randi_range(0, colors.size()-1)]
			artifact_layer.add_child(frag)

	var frame_times = [0.04, 0.03, 0.05, 0.03, 0.06, 0.03, 0.04, 0.05, 0.03, 0.07, 0.04, 0.03]

	for t in frame_times:
		spawn_artifacts.call()
		glitch_overlay.color = Color(0, 0, 0, rng.randf_range(0.3, 0.75))
		await get_tree().create_timer(t).timeout

	for child in artifact_layer.get_children():
		child.queue_free()
	glitch_overlay.color = Color(0, 0, 0, 1.0)
	await get_tree().create_timer(0.12).timeout

	var tween = create_tween()
	tween.tween_property(glitch_overlay, "color", Color(0, 0, 0, 0), 0.2)
	await tween.finished

	artifact_layer.queue_free()
	glitch_overlay.color = Color(0, 0, 0, 0)

func open_blocking_browser(scene: PackedScene, app_name: String):
	blocking_layer.visible = true
	var window = scene.instantiate()
	blocking_layer.add_child(window)
	window.set_title(app_name)
	await get_tree().process_frame
	window.position = (get_viewport_rect().size - window.size) / 2.0

func _on_login_success():
	login_active = false
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

func get_center_spawn(window: Control) -> Vector2:
	var viewport_size = get_viewport_rect().size
	return (viewport_size - window.size) / 2.0

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

	if spawn_pos == Vector2.ZERO:
		window.position = cascade_pos
		_advance_cascade()
	elif spawn_pos == Vector2(-1, -1):
		await get_tree().process_frame
		window.position = get_center_spawn(window)
	else:
		window.position = spawn_pos

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
		alert.position = get_center_spawn(alert)

	request_focus(alert)

func install_toque_dourado_delayed(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	show_alert("Toque Dourado foi instalado com sucesso.")
	spawn_new_desktop_file(
		"Toque Dourado",
		preload("res://scenes/interactables/computer/toque_dourado_app.tscn"),
		false,
		Vector2.ZERO,
		preload("res://arts/images/PC/midastouch-export.png")
	)
	spawn_new_desktop_file(
		"Messenger",
		preload("res://scenes/interactables/computer/messager.tscn"),
		true,
		Vector2(920, 680),
		preload("res://arts/images/PC/messenger-export.png")
	)

func spawn_new_desktop_file(
	app_name: String,
	scene: PackedScene,
	hide_by_gold := false,
	custom_position := Vector2.ZERO,
	icon_texture: Texture2D = null
) -> void:
	var icon_scene = preload("res://scenes/interactables/computer/desktop_app_icons.tscn")
	var icon = icon_scene.instantiate() as DesktopAppIcon

	if custom_position != Vector2.ZERO:
		loose_icon_layer.add_child(icon)
		icon.position = custom_position
		icon.custom_minimum_size = Vector2(96, 110)
		icon.size = Vector2(96, 110)
	else:
		$Desktop_Root/Desktop_Icons.add_child(icon)

	var tex = icon_texture if icon_texture else preload("res://arts/test/midastoque_test.png")
	icon.setup(scene, app_name, tex)

	if hide_by_gold:
		icon.hide_by_gold()
