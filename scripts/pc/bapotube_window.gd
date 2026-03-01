extends WindowBase
class_name BapoTubeApp

@onready var mostrar_mais_btn: Button = $Content/VBox/PageScroll/PageVBox/InfoMargin/InfoVBox/DescPanel/DescVBox/MostrarMaisBtn
@onready var expanded_vbox: VBoxContainer = $Content/VBox/PageScroll/PageVBox/InfoMargin/InfoVBox/DescPanel/DescVBox/ExpandedVBox
@onready var symbol_btn: Button = $Content/VBox/PageScroll/PageVBox/InfoMargin/InfoVBox/DescPanel/DescVBox/ExpandedVBox/SymbolBtn

var alert_triggered := false

func _ready():
	super._ready()
	expanded_vbox.visible = false
	mostrar_mais_btn.pressed.connect(_on_mostrar_mais)
	symbol_btn.pressed.connect(_on_symbol_clicked)
	_apply_address_bar_style()

func _apply_address_bar_style() -> void:
	# Fundo geral da barra — mesma linguagem do browser
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.95, 0.95, 0.95, 1)
	bar_bg.set_content_margin_all(6)
	bar_bg.border_color = Color(0.45, 0.45, 0.45, 1)
	bar_bg.border_width_bottom = 2
	$Content/VBox/BrowserBar.add_theme_stylebox_override("panel", bar_bg)

	# Estilo dos botoes (◄ ►)
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

	for btn_name in ["BackBtn", "ForwardBtn"]:
		var btn = $Content/VBox/BrowserBar/BarHBox.get_node_or_null(btn_name) as Button
		if btn:
			btn.add_theme_stylebox_override("normal", btn_normal)
			btn.add_theme_stylebox_override("hover", btn_hover)
			btn.add_theme_stylebox_override("pressed", btn_pressed)
			btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1, 1))
			btn.add_theme_color_override("font_hover_color", Color(0.0, 0.35, 0.9, 1))
			btn.add_theme_font_size_override("font_size", 33)

	# URLBar — LineEdit nao editavel (so mostra a URL atual)
	var url_bar = $Content/VBox/BrowserBar/BarHBox.get_node_or_null("URLBar")
	if url_bar:
		var le_style = StyleBoxFlat.new()
		le_style.bg_color = Color(1.0, 1.0, 1.0, 1)
		le_style.set_corner_radius_all(4)
		le_style.set_content_margin_all(5)
		le_style.border_color = Color(0.72, 0.72, 0.72, 1)
		le_style.set_border_width_all(1)
		url_bar.add_theme_stylebox_override("normal", le_style)
		url_bar.add_theme_stylebox_override("read_only", le_style)
		url_bar.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08, 1))
		url_bar.add_theme_font_size_override("font_size", 33)

func _on_mostrar_mais():
	expanded_vbox.visible = true
	mostrar_mais_btn.visible = false

func _on_symbol_clicked():
	if alert_triggered:
		return
	alert_triggered = true
	_trigger_alert()

func _trigger_alert():
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if not pc:
		return
	var scene = preload("res://scenes/interactables/computer/alert_window.tscn")
	pc.open_window(scene, "Aviso", Vector2(-1, -1))
	await get_tree().process_frame
	var alert := pc.open_windows.get("Aviso") as AlertWindow
	if not alert:
		return
	alert.minimize_button.disabled = true
	alert.set_message("A pista está na maleta dele, o código é 125.")
	alert.tree_exited.connect(_open_browser)
	GameEvents.dialogue_requested.emit([
	{speaker = "Você:", text = "Ah, me lembro desta senha."},
	{speaker = "Você", text = "É da maleta no meu armário"},
	])
	await GameEvents.dialogue_finished
	GameManager.set_flag("puzzle3_done", true)
	

func _open_browser():
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if not pc:
		return
	await pc.play_glitch()
	pc.open_blocking_browser(
		preload("res://scenes/interactables/computer/browser_window.tscn"),
		"Navegador"
		)
