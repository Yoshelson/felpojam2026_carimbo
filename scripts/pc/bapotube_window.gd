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
	var alert = scene.instantiate()
	pc.window_layer.add_child(alert)
	alert.set_title("Aviso")
	alert.set_message("A pista está na maleta dele, o código é 125.")
	await get_tree().process_frame
	alert.position = pc.get_center_spawn(alert)
	pc.request_focus(alert)
	alert.tree_exited.connect(_open_browser)
	GameEvents.dialogue_requested.emit([
	{speaker = "Você:", text = "Ah, me lembro desta senha."},
	{speaker = "Você", text = "É da maleta no meu armário"},
	])
	await GameEvents.dialogue_finished
	

func _open_browser():
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if not pc:
		return
	await pc.play_glitch()
	pc.open_blocking_browser(
		preload("res://scenes/interactables/computer/browser_window.tscn"),
		"Navegador"
		)
