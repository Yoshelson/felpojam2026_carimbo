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
@export var typewrite_speed: float = 0.03
@export var fade_duration: float = 0.35

@onready var panel: PanelContainer = $Control/PanelContainer
@onready var name_label: RichTextLabel = $Control/PanelContainer/MarginContainer/VBox/NameLabel
@onready var text_label: RichTextLabel = $Control/PanelContainer/MarginContainer/VBox/TextLabel
@onready var click_hint: Label = $Control/PanelContainer/MarginContainer/VBox/ClickHint
@onready var control: Control = $Control

var dialogue_queue: Array = []
var is_showing: bool = false
var _waiting_click: bool = false

# Flag pública — true durante TODO diálogo e subtitles. Usada por PC e Documentos.
var is_dialogue_active: bool = false

# Mouse mode salvo antes do diálogo para restaurar corretamente ao final
var _mouse_mode_before_dialogue: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

# Flag de skip para subtitles (sistema simples, sem clique obrigatório)
var _subtitle_skip: bool = false

func _ready() -> void:
	add_to_group("subtitle_ui")
	process_mode = Node.PROCESS_MODE_PAUSABLE
	set_process_input(false)
	control.modulate.a = 0.0
	_apply_style()
	GameEvents.subtitle_requested.connect(_on_subtitle_requested)
	GameEvents.dialogue_requested.connect(_on_dialogue_requested)

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

# --- SISTEMA SIMPLES (subtitle_requested) ---

func _on_subtitle_requested(speaker: String, new_text: String, duration: float) -> void:
	dialogue_queue.append({"name": speaker, "text": new_text, "duration": duration})
	if not is_showing:
		_show_next()

func _show_next() -> void:
	if dialogue_queue.is_empty():
		is_showing = false
		is_dialogue_active = false
		var tween = create_tween()
		tween.tween_property(control, "modulate:a", 0.0, fade_duration)
		return

	is_showing = true
	is_dialogue_active = true
	_subtitle_skip = false
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

	# Se o jogador clicou durante o typewrite, mostra o texto completo e avança
	if _subtitle_skip:
		_subtitle_skip = false
		_show_next()
		return

	# Espera a duração checando skip a cada 0.05s — permite pular com clique
	var elapsed := 0.0
	while elapsed < entry["duration"] and not _subtitle_skip:
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05

	_subtitle_skip = false
	_show_next()

func _typewrite() -> void:
	await get_tree().create_timer(0.0).timeout
	await get_tree().create_timer(0.0).timeout
	var total = text_label.get_total_character_count()
	for i in range(total):
		if _subtitle_skip:
			# Mostra o texto inteiro de uma vez ao pular
			text_label.visible_characters = total
			return
		text_label.visible_characters = i + 1
		await get_tree().create_timer(typewrite_speed).timeout

# Captura cliques para skip de subtitles APENAS (não interfere em diálogos)
# Diálogos usam _input() + set_process_input(true) separadamente
func _unhandled_input(event: InputEvent) -> void:
	# Só opera durante subtitles simples: is_showing=true mas _waiting_click=false
	if not is_showing or _waiting_click:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_subtitle_skip = true
		get_viewport().set_input_as_handled()

# --- SISTEMA COM CLIQUE (dialogue_requested) ---

func _on_dialogue_requested(lines: Array) -> void:
	_show_priority(lines)

func _show_priority(lines: Array) -> void:
	_mouse_mode_before_dialogue = Input.get_mouse_mode()
	is_dialogue_active = true
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	control.modulate.a = 1.0
	click_hint.visible = false

	for line in lines:
		name_label.visible = line.speaker != ""
		name_label.text = line.speaker
		text_label.text = ""
		text_label.visible_characters = 0
		await _typewrite_priority(line.text)
		_waiting_click = true
		click_hint.visible = true
		await _wait_for_click()
		click_hint.visible = false

	control.modulate.a = 0.0
	_waiting_click = false
	is_dialogue_active = false
	set_process_input(false)
	Input.set_mouse_mode(_mouse_mode_before_dialogue)
	GameEvents.dialogue_finished.emit()

func _typewrite_priority(full_text: String) -> void:
	text_label.text = full_text
	text_label.visible_characters = 0
	await get_tree().create_timer(0.0).timeout
	await get_tree().create_timer(0.0).timeout
	var total = text_label.get_total_character_count()
	for i in range(total):
		text_label.visible_characters = i + 1
		await get_tree().create_timer(typewrite_speed).timeout

func _wait_for_click() -> void:
	while _waiting_click:
		await get_tree().create_timer(0.05).timeout

func _input(event: InputEvent) -> void:
	if not _waiting_click:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_waiting_click = false
		get_viewport().set_input_as_handled()
