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
