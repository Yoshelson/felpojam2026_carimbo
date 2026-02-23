extends WindowBase
class_name MessengerApp

@onready var contacts_list = $Content/HBoxContainer/ContactsPanel/VBoxContainer
@onready var chat_history = $Content/HBoxContainer/ChatPanel/VBoxContainer/ChatHistory

var conversations = {}
var current_contact = ""


func _ready():
	super._ready()
	setup_contacts()
	
	chat_history.bbcode_enabled = true
	chat_history.meta_clicked.connect(_on_link_clicked)


# cria contatos e conversas fixas
func setup_contacts():
	add_contact("Felpo")
	add_contact("Desconhecido")
	
	conversations["Felpo"] = [
		"Felpo: você viu isso?",
		"Felpo: olha esse vídeo estranho...",
		"[color=blue][url=https://midastube.local/watch?v=001]https://midastube.local/watch?v=001[/url][/color]"
	]
	
	conversations["Desconhecido"] = [
		"??? : você não deveria estar vendo isso.",
		"??? : ele já sabe."
	]


func add_contact(_contact_name):
	var btn = Button.new()
	btn.text = name
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(func(): open_conversation(name))
	contacts_list.add_child(btn)


func open_conversation(_contact_name):
	current_contact = name
	chat_history.clear()
	
	for line in conversations[name]:
		chat_history.append_text(line + "\n\n")


# abre o app midastube ao clicar no link
func _on_link_clicked(_meta):
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if pc:
		pc.open_window(load("res://scenes/interactables/computer/audio_player.tscn"), "MidasTube")
