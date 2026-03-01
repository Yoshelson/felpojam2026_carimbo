extends WindowBase
class_name BrowserApp

@onready var url_prefix: Label = $Content/VBox/BrowserBar/BarHBox/URLPrefix
@onready var url_input: LineEdit = $Content/VBox/BrowserBar/BarHBox/URLInput
@onready var url_fixed: Label = $Content/VBox/BrowserBar/BarHBox/URLFixed
@onready var search_btn: Button = $Content/VBox/BrowserBar/BarHBox/SearchBtn
@onready var page_scroll: ScrollContainer = $Content/VBox/PageScroll
@onready var poem_page: Control = $Content/VBox/PageScroll/PageVBox/PoemPage
@onready var monochrome_page: Control = $Content/VBox/PageScroll/PageVBox/MonochromePage
@onready var monochrome_symbol: Button = $Content/VBox/PageScroll/PageVBox/MonochromePage/MonoVBox/SymbolBtn
@onready var puzzle_page: Control = $Content/VBox/PageScroll/PageVBox/PuzzlePage
@onready var final_page: Control = $Content/VBox/PageScroll/PageVBox/FinalPage

const PASSWORD = "aluaminguante"
const CORRECT_SEQUENCE = [1, 2, 3, 4, 5, 6, 7, 8, 9]

const ANIMAL_TEXTURES = {
	1: ["res://arts/images/PC/buttons_animals/animal1.png", "res://arts/images/PC/buttons_animals/animal1_on.png"],
	2: ["res://arts/images/PC/buttons_animals/animal2.png", "res://arts/images/PC/buttons_animals/animal2_on.png"],
	3: ["res://arts/images/PC/buttons_animals/animal3.png", "res://arts/images/PC/buttons_animals/animal3_on.png"],
	4: ["res://arts/images/PC/buttons_animals/animal4.png", "res://arts/images/PC/buttons_animals/animal4_on.png"],
	5: ["res://arts/images/PC/buttons_animals/animal5.png", "res://arts/images/PC/buttons_animals/animal5_on.png"],
	6: ["res://arts/images/PC/buttons_animals/animal6.png", "res://arts/images/PC/buttons_animals/animal6_on.png"],
	7: ["res://arts/images/PC/buttons_animals/animal7.png", "res://arts/images/PC/buttons_animals/animal7_on.png"],
	8: ["res://arts/images/PC/buttons_animals/animal8.png", "res://arts/images/PC/buttons_animals/animal8_on.png"],
	9: ["res://arts/images/PC/buttons_animals/animal9.png", "res://arts/images/PC/buttons_animals/animal9_on.png"],
}

var current_sequence: Array = []
var puzzle_solved := false
var navigated := false
var hint := true

func _ready():
	super._ready()
	close_button.disabled = true
	minimize_button.disabled = true

	monochrome_page.visible = false
	puzzle_page.visible = false
	final_page.visible = false
	url_fixed.visible = false

	url_input.text_submitted.connect(_on_navigate)
	search_btn.pressed.connect(func(): _on_navigate(url_input.text))
	monochrome_symbol.pressed.connect(_trigger_monochrome_alert)

	url_input.text_changed.connect(func(t):
		url_input.text = t.to_lower()
		url_input.caret_column = url_input.text.length()
	)

	for i in range(1, 10):
		var btn = puzzle_page.get_node("PuzzleMargin/PuzzleCenter/Grid/Animal%d" % i) as Button
		if btn:
			var icon_off = btn.get_node("icon") as TextureRect
			var icon_on = btn.get_node("icon_on") as TextureRect
			if icon_off and ANIMAL_TEXTURES.has(i):
				icon_off.texture = load(ANIMAL_TEXTURES[i][0])
			if icon_on and ANIMAL_TEXTURES.has(i):
				icon_on.texture = load(ANIMAL_TEXTURES[i][1])
				icon_on.visible = false
			btn.pressed.connect(_on_animal_pressed.bind(i))

	# imagem dica abaixo do grid
	var hint_img = TextureRect.new()
	hint_img.texture = load("res://arts/images/PC/buttons_animals/color_sequence.png")
	hint_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hint_img.custom_minimum_size = Vector2(0, 120)
	hint_img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	puzzle_page.get_node("PuzzleMargin").add_child(hint_img)

	_apply_address_bar_style()

func _apply_address_bar_style() -> void:
	# Fundo geral da barra — cinza muito claro com borda inferior
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.95, 0.95, 0.95, 1)
	bar_bg.set_content_margin_all(6)
	bar_bg.border_color = Color(0.45, 0.45, 0.45, 1)
	bar_bg.border_width_bottom = 2
	$Content/VBox/BrowserBar.add_theme_stylebox_override("panel", bar_bg)

	# Estilo dos botoes (◄ ► →) — fundo branco, borda cinza, hover azul claro
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(1.0, 1.0, 1.0, 1)
	btn_normal.set_corner_radius_all(4)
	btn_normal.set_content_margin_all(6)
	btn_normal.border_color = Color(0.72, 0.72, 0.72, 1)
	btn_normal.set_border_width_all(1)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.88, 0.93, 1.0, 1)
	btn_hover.set_corner_radius_all(4)
	btn_hover.set_content_margin_all(6)
	btn_hover.border_color = Color(0.35, 0.6, 1.0, 1)
	btn_hover.set_border_width_all(1)

	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = Color(0.78, 0.88, 1.0, 1)
	btn_pressed.set_corner_radius_all(4)
	btn_pressed.set_content_margin_all(6)
	btn_pressed.border_color = Color(0.2, 0.5, 0.95, 1)
	btn_pressed.set_border_width_all(2)

	for btn_name in ["BackBtn", "ForwardBtn", "SearchBtn"]:
		var btn = $Content/VBox/BrowserBar/BarHBox.get_node_or_null(btn_name) as Button
		if btn:
			btn.add_theme_stylebox_override("normal", btn_normal)
			btn.add_theme_stylebox_override("hover", btn_hover)
			btn.add_theme_stylebox_override("pressed", btn_pressed)
			btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1, 1))
			btn.add_theme_color_override("font_hover_color", Color(0.0, 0.35, 0.9, 1))
			btn.add_theme_color_override("font_pressed_color", Color(0.0, 0.2, 0.75, 1))
			btn.add_theme_font_size_override("font_size", 33)

	# URLPrefix — label cinza escuro, fonte maior
	url_prefix.add_theme_color_override("font_color", Color(0.28, 0.28, 0.28, 1))
	url_prefix.add_theme_font_size_override("font_size", 33)

	# URLFixed — texto preto apos navegar
	url_fixed.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08, 1))
	url_fixed.add_theme_font_size_override("font_size", 33)

	# URLInput — LineEdit onde o jogador digita a senha do puzzle
	var le_normal = StyleBoxFlat.new()
	le_normal.bg_color = Color(1.0, 1.0, 1.0, 1)
	le_normal.set_corner_radius_all(4)
	le_normal.set_content_margin_all(5)
	le_normal.border_color = Color(0.7, 0.7, 0.7, 1)
	le_normal.set_border_width_all(1)

	var le_focus = StyleBoxFlat.new()
	le_focus.bg_color = Color(1.0, 1.0, 1.0, 1)
	le_focus.set_corner_radius_all(4)
	le_focus.set_content_margin_all(5)
	le_focus.border_color = Color(0.25, 0.55, 1.0, 1)
	le_focus.set_border_width_all(2)

	url_input.add_theme_stylebox_override("normal", le_normal)
	url_input.add_theme_stylebox_override("focus", le_focus)
	url_input.add_theme_stylebox_override("read_only", le_normal)
	url_input.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08, 1))
	url_input.add_theme_color_override("font_placeholder_color", Color(0.3, 0.3, 0.3, 1))
	url_input.add_theme_color_override("caret_color", Color(0.08, 0.08, 0.08, 1))
	url_input.add_theme_color_override("selection_color", Color(0.25, 0.55, 1.0, 0.35))
	url_input.add_theme_font_size_override("font_size", 33)
	url_input.placeholder_text = "digite um endereco..."

func _set_animal_active(index: int, active: bool) -> void:
	var btn = puzzle_page.get_node("PuzzleMargin/PuzzleCenter/Grid/Animal%d" % index) as Button
	if not btn:
		return
	btn.get_node("icon").visible = not active
	btn.get_node("icon_on").visible = active

func _reset_all_animals() -> void:
	for i in range(1, 10):
		_set_animal_active(i, false)

func _on_close_pressed():
	GameEvents.subtitle_requested.emit("Você", "Não quer fechar.", 2)

func puzzle_hint():
	if hint:
		GameEvents.subtitle_requested.emit("Você", "Um poema?", 2)
		GameEvents.subtitle_requested.emit("Você", "Talvez seja melhor eu rever os [color=yellow]documentos[/color].", 3.5)
		hint = false

func _on_navigate(text: String):
	if navigated:
		return
	if text.strip_edges() == PASSWORD:
		navigated = true
		url_prefix.visible = false
		url_input.visible = false
		url_fixed.visible = true
		url_fixed.text = "www.lanoceu.tem/aluaminguante"
		search_btn.visible = false
		poem_page.visible = false
		monochrome_page.visible = true
		page_scroll.scroll_vertical = 0

func _trigger_monochrome_alert():
	monochrome_symbol.disabled = true
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if not pc:
		return
	var scene = preload("res://scenes/interactables/computer/alert_window.tscn")
	var alert = scene.instantiate()
	pc.blocking_layer.add_child(alert)
	alert.set_title("")
	alert.set_message("prossiga.")
	await get_tree().process_frame
	alert.position = pc.get_center_spawn(alert)
	alert.tree_exited.connect(_show_puzzle)

func _show_puzzle():
	monochrome_page.visible = false
	puzzle_page.visible = true
	url_fixed.text = "www.ocaminho.onde/sequencia"
	page_scroll.scroll_vertical = 0
	current_sequence = []
	_reset_all_animals()

func _on_animal_pressed(index: int):
	if puzzle_solved:
		return
	
	_set_animal_active(index, true)
	current_sequence.append(index)
	
	for i in current_sequence.size():
		if current_sequence[i] != CORRECT_SEQUENCE[i]:
			await get_tree().create_timer(0.3).timeout
			_reset_all_animals()
			current_sequence = []
			return

	if current_sequence.size() == CORRECT_SEQUENCE.size():
		puzzle_solved = true
		GameManager.set_flag("puzzle5_done", true)
		puzzle_page.visible = false
		final_page.visible = true
		url_fixed.text = "www.pontodeencontro.aqui/fim"
		page_scroll.scroll_vertical = 0

func _on_url_input_focus_entered() -> void:
	puzzle_hint()
