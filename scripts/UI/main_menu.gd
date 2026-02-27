extends Control

@export var parallax_strength: float = 8.0
@export var parallax_smoothness: float = 6.0

@onready var container: Control = $PanelContainer
@onready var main_menu_panel: Control = $PanelContainer/main_menu
@onready var settings_panel: Control = $PanelContainer/settings_menu
@onready var credits_panel: Control = $PanelContainer/credits_menu

@export var menu_music: AudioStream

const HOVER_SCALE := 1.15
const HOVER_SPEED := 11.0
const PANEL_WIDTH := 1366.0

var main_panel: Control
var menu_buttons: Array = []
var focused_index: int = 0
var is_animating: bool = false
var current_panel: Control
var viewport_size: Vector2
var base_position: Vector2

func _ready():
	viewport_size = get_viewport().size
	current_panel = main_menu_panel

	container.clip_contents = true

	main_menu_panel.visible = true
	settings_panel.visible = true
	credits_panel.visible = true

	main_menu_panel.position = Vector2.ZERO
	settings_panel.position = Vector2(PANEL_WIDTH, 0)
	credits_panel.position = Vector2(PANEL_WIDTH, 0)

	await get_tree().process_frame

	main_panel = main_menu_panel.get_node("VBoxContainer")
	base_position = main_panel.position

	_setup_settings()
	_collect_buttons()
	_connect_buttons()
	_apply_menu_style_to_settings()
	await get_tree().create_timer(1).timeout
	MusicManager.crossfade_to(menu_music, 1)

func _setup_settings():
	settings_panel.get_node("VBoxContainer/settings_tab/Gráficos/VBox/HBox/fullscreen").button_pressed = \
		true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else false
	settings_panel.get_node("VBoxContainer/settings_tab/Sons/VBox/HBoxMaster/volMaster").value = \
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	settings_panel.get_node("VBoxContainer/settings_tab/Sons/VBox/HBoxMusic/volMusic").value = \
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MUSIC")))
	settings_panel.get_node("VBoxContainer/settings_tab/Sons/VBox/HBoxSfx/volSfx").value = \
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

func _collect_buttons():
	menu_buttons.clear()
	var vbox = main_menu_panel.get_node("VBoxContainer")
	for child in vbox.get_children():
		if child is Button:
			menu_buttons.append(child)
			child.mouse_entered.connect(_on_button_hover.bind(child))
			child.mouse_exited.connect(_on_button_unhover.bind(child))

func _connect_buttons():
	var vbox = main_menu_panel.get_node("VBoxContainer")
	vbox.get_node("Button").pressed.connect(_on_start_pressed)
	vbox.get_node("Button2").pressed.connect(_on_configurations_pressed)
	vbox.get_node("Button3").pressed.connect(_on_credits_pressed)
	vbox.get_node("Button4").pressed.connect(_on_quit_pressed)

	settings_panel.get_node("VBoxContainer/BtnVoltar").pressed.connect(_on_back_pressed)
	credits_panel.get_node("VBoxContainer/BtnVoltar").pressed.connect(_on_back_pressed)

	var fs = settings_panel.get_node("VBoxContainer/settings_tab/Gráficos/VBox/HBox/fullscreen")
	fs.toggled.connect(func(on):
		if on:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	)
	settings_panel.get_node("VBoxContainer/settings_tab/Sons/VBox/HBoxMaster/volMaster").value_changed.connect(func(v):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), v)
	)
	settings_panel.get_node("VBoxContainer/settings_tab/Sons/VBox/HBoxMusic/volMusic").value_changed.connect(func(v):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("MUSIC"), v)
	)
	settings_panel.get_node("VBoxContainer/settings_tab/Sons/VBox/HBoxSfx/volSfx").value_changed.connect(func(v):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), v)
	)

func _apply_menu_style_to_settings():
	var font = load("res://arts/Unutterable-Regular.ttf")
	var color = Color(1, 1, 0.26666668, 1)
	var color_dark = Color(1, 1, 0.26666668, 0.4)

	for node in _get_all_children(settings_panel):
		if node is Label:
			node.add_theme_font_override("font", font)
			node.add_theme_font_size_override("font_size", 28)
			node.add_theme_color_override("font_color", color)
		elif node is Button or node is CheckButton:
			node.add_theme_font_override("font", font)
			node.add_theme_font_size_override("font_size", 28)
			node.add_theme_color_override("font_color", color)
			node.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
			node.add_theme_color_override("font_pressed_color", color)
			node.flat = true
		elif node is TabContainer:
			node.add_theme_font_override("font", font)
			node.add_theme_font_size_override("font_size", 24)
			node.add_theme_color_override("font_unselected_color", color_dark)
			node.add_theme_color_override("font_selected_color", color)
		elif node is HSlider:
			node.add_theme_stylebox_override("slider", _make_flat_stylebox(color_dark, 4))
			node.add_theme_stylebox_override("grabber_area", _make_flat_stylebox(color, 4))
			node.add_theme_icon_override("grabber", _make_grabber_texture(color))

func _make_flat_stylebox(color: Color, height: int) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(height)
	sb.content_margin_top = height / 2.0
	sb.content_margin_bottom = height / 2.0
	return sb

func _make_grabber_texture(color: Color) -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in 16:
		for y in 16:
			var dx = x - 8.0
			var dy = y - 8.0
			if dx * dx + dy * dy <= 36.0:
				img.set_pixel(x, y, color)
	return ImageTexture.create_from_image(img)

func _get_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_get_all_children(child))
	return result

func _process(delta):
	if main_panel:
		_handle_parallax(delta)
	_handle_hover_scale(delta)

func _handle_parallax(delta):
	var mouse = get_viewport().get_mouse_position()
	var normalized = Vector2(
		(mouse.x / viewport_size.x) * 2.0 - 1.0,
		(mouse.y / viewport_size.y) * 2.0 - 1.0
	)
	var target = base_position + normalized * parallax_strength
	main_panel.position = main_panel.position.lerp(target, parallax_smoothness * delta)

func _handle_hover_scale(delta):
	for i in menu_buttons.size():
		var btn: Button = menu_buttons[i]
		var is_focused = (i == focused_index and current_panel == main_menu_panel)
		var target_scale = Vector2(HOVER_SCALE, HOVER_SCALE) if is_focused else Vector2.ONE
		btn.scale = btn.scale.lerp(target_scale, HOVER_SPEED * delta)
		btn.pivot_offset = btn.size / 2.0

func _on_button_hover(btn: Button):
	var idx = menu_buttons.find(btn)
	if idx != -1:
		focused_index = idx

func _on_button_unhover(_btn: Button):
	pass

func _input(event):
	if not main_panel:
		return
	if current_panel == main_menu_panel:
		if event.is_action_pressed("ui_down"):
			focused_index = (focused_index + 1) % menu_buttons.size()
		elif event.is_action_pressed("ui_up"):
			focused_index = (focused_index - 1 + menu_buttons.size()) % menu_buttons.size()
		elif event.is_action_pressed("ui_accept"):
			menu_buttons[focused_index].emit_signal("pressed")
	elif current_panel == settings_panel or current_panel == credits_panel:
		if event.is_action_pressed("ui_cancel"):
			_on_back_pressed()

func _slide_to(from: Control, to: Control, going_right: bool) -> void:
	if is_animating:
		return
	is_animating = true

	var dist = PANEL_WIDTH
	var dir = 1 if going_right else -1

	to.position.x = dist * dir

	var tween = create_tween().set_parallel(true)
	tween.tween_property(from, "position:x", -dist * dir, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(from, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
	tween.tween_property(to, "position:x", 0.0, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(to, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	await tween.finished

	from.modulate.a = 1.0
	from.position.x = -dist * dir
	current_panel = to
	is_animating = false

func _on_configurations_pressed():
	_slide_to(main_menu_panel, settings_panel, true)

func _on_credits_pressed():
	_slide_to(main_menu_panel, credits_panel, true)

func _on_back_pressed():
	_slide_to(current_panel, main_menu_panel, false)

func _on_start_pressed():
	_fade_to("res://scenes/base.tscn")

func _on_quit_pressed():
	_fade_out_and_quit()

func _fade_to(scene_path: String) -> void:
	if is_animating:
		return
	is_animating = true
	
	var overlay = _create_overlay()
	var tween = create_tween()
	tween.tween_property(overlay, "color", Color(0, 0, 0, 1), 0.6)
	
	await tween.finished
	get_tree().change_scene_to_file(scene_path)

func _fade_out_and_quit() -> void:
	if is_animating:
		return
	
	is_animating = true
	
	var music_tween = MusicManager.stop_music(1)
	
	var overlay = _create_overlay()
	var tween = create_tween()
	tween.tween_property(overlay, "color", Color(0, 0, 0, 1), 0.6)
	
	await tween.finished
	await music_tween.finished
	get_tree().quit()

func _create_overlay() -> ColorRect:
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	return overlay
