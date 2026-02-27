extends CanvasLayer

@export_group("Fonte")
@export var font: Font
@export var font_size: int = 28
@export var name_font_size: int = 24
@export var text_color: Color = Color(1, 1, 1, 1)
@export var name_color: Color = Color(1, 0.85, 0.3, 1)

@export_group("Fundo")
@export var bg_color: Color = Color(0.05, 0.05, 0.1, 0.82)
@export var bg_corner_radius: int = 10

@export_group("Animação")
@export var typewrite_speed: float = 0.04
@export var fade_duration: float = 0.5

@onready var panel: PanelContainer = $Control/PanelContainer
@onready var name_label: RichTextLabel = $Control/PanelContainer/MarginContainer/VBox/NameLabel
@onready var text_label: RichTextLabel = $Control/PanelContainer/MarginContainer/VBox/TextLabel
@onready var control: Control = $Control

var dialogue_queue: Array = []
var is_showing: bool = false

func _ready() -> void:
	control.modulate.a = 0.0
	_apply_style()
	GameEvents.subtitle_requested.connect(_on_subtitle_requested)

func _apply_style() -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.set_corner_radius_all(bg_corner_radius)
	sb.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", sb)

	for label in [name_label, text_label]:
		label.bbcode_enabled = true
		if font:
			label.add_theme_font_override("normal_font", font)
		label.add_theme_color_override("default_color", text_color)

	name_label.add_theme_font_size_override("normal_font_size", name_font_size)
	text_label.add_theme_font_size_override("normal_font_size", font_size)

func _on_subtitle_requested(speaker: String, new_text: String, duration: float) -> void:
	dialogue_queue.append({"name": speaker, "text": new_text, "duration": duration})
	if not is_showing:
		_show_next()

func _show_next() -> void:
	if dialogue_queue.is_empty():
		is_showing = false
		var tween = create_tween()
		tween.tween_property(control, "modulate:a", 0.0, fade_duration)
		return

	is_showing = true
	var entry = dialogue_queue.pop_front()

	if entry["name"] != "":
		name_label.visible = true
		name_label.text = entry["name"]
	else:
		name_label.visible = false

	text_label.text = entry["text"]
	text_label.visible_characters = 0

	var tween_in = create_tween()
	tween_in.tween_property(control, "modulate:a", 1.0, fade_duration)
	await tween_in.finished

	await _typewrite()
	await get_tree().create_timer(entry["duration"]).timeout
	_show_next()

func _typewrite() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var total = text_label.get_total_character_count()
	for i in range(total):
		text_label.visible_characters = i + 1
		await get_tree().create_timer(typewrite_speed).timeout
