extends Control
class_name PCControl


@onready var window_layer = $Desktop_Root/DraggablePanel/WindowLayer
@onready var taskbar_app_list = $Desktop_Root/Taskbar/AppContainer


@onready var mouse_cursor: Sprite2D = $Mouse
var pc_mouse_pos:Vector2 = Vector2.ZERO

@export var panel_windows:Array[DraggablePanelContainer]

signal exit_requested

@onready var exit_button: Button = $Desktop_Test/Quit


var top_z := 1

func request_focus(panel):
	top_z += 1
	panel.z_index = top_z

	# Marca botão da taskbar como ativo
	var btn = panel.get_meta("taskbar_button")
	if btn:
		btn.button_pressed = true

func _ready():
	exit_button.pressed.connect(_on_exit_pressed)
	$LoginScreen.login_success.connect(_on_login_success)
	add_to_group("pc_control")
	
	open_window(preload("res://scenes/interactables/computer/window_base.tscn"), "Meus Arquivos")

func _on_login_success():
	print("Login realizado")

func _on_exit_pressed():
	emit_signal("exit_requested")


func update_cursor_pos():
	mouse_cursor.position = pc_mouse_pos
	
	

func open_window(scene: PackedScene, app_name: String):
	# Fecha instância existente se houver
	if open_windows.has(app_name):
		var existing_window = open_windows[app_name]
		if existing_window and existing_window.is_inside_tree():
			existing_window.queue_free()

	# Cria nova instância
	var window = scene.instantiate()
	window_layer.add_child(window)
	window.set_title(app_name)

	# Conecta sinais de minimizar e fechar
	window.minimized.connect(_on_window_minimized)
	window.tree_exited.connect(_on_window_closed.bind(app_name))

	# Cria botão na taskbar
	_add_taskbar_button(window, app_name)

	# Foca a janela
	request_focus(window)

	# Salva no dicionário de instâncias
	open_windows[app_name] = window

var open_windows := {}

func _on_window_minimized(window):
	var btn = window.get_meta("taskbar_button")
	if btn:
		btn.button_pressed = false

func _on_window_closed(app_name):
	if open_windows.has(app_name):
		var btn = open_windows[app_name].get_meta("taskbar_button")
		if btn:
			btn.queue_free()
		open_windows.erase(app_name)


func _add_taskbar_button(window, _app_name: String):
	var btn = Button.new()
	btn.toggle_mode = true
	btn.button_pressed = true
	btn.text = ""  
	btn.flat = true
	btn.custom_minimum_size = Vector2(48, 48)

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



#teste



#func spawn_test_window():
	#var window = preload("res://scenes/window_base.tscn").instantiate()
	#$Desktop_Root/WindowLayer.add_child(window)
#
	#window.size = Vector2(400, 300)
	#window.set_title("Teste")
#
	#window.position = -window.size * 0.5
