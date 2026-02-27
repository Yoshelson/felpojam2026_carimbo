extends WindowBase
class_name MessengerApp

@onready var contacts_list = $Content/HBoxContainer/ContactsPanel/ContactsMargin/ContactsList
@onready var contact_name_label = $Content/HBoxContainer/ChatPanel/ChatMargin/ChatVBox/ContactNameLabel
@onready var chat_history = $Content/HBoxContainer/ChatPanel/ChatMargin/ChatVBox/ChatHistory

const CONVERSATIONS = {
	"Contato 1": [
		{"from": "Desconhecido",  "text": "Você acha que não sei o que está fazendo?"},
		{"from": "Desconhecido",  "text": "Pode ter certeza que vou fazer você se arrepender."},
	],
	"Contato 2": [
		{"from": "gisele_09", "text": "não aguento mais essa sua fase"},
		{"from": "gisele_09", "text": "entendo quando vc ainda era criança Monique, mas e isso agora?"},
		{"from": "gisele_09", "text": "2 anos tendo que te ouvir numa cela e lidando com a burrada que você fez?"},
		{"from": "gisele_09", "text": "e aí o que?"},
		{"from": "gisele_09", "text": "que um abraço, 'te amo, irmã' e tudo se resolve?"},
		{"from": "gisele_09", "text": "pra mim já chega, vc que aprenda as consequências e não tente me ligar mais."},
		{"from": "gisele_09", "text": "é verdade, vou sair um pouco pelo menos"},
		{"from": "gisele_09", "text": "eu quero ter uma vida"},
		{"from": "eu", "text": "Eu sei que eu fui egoísta mas um dia vou te fazer entender tudo."},
		{"from": "eu", "text": "Eu prometo."}
	],
	"Contato 3": [
		{"from": "observe", "text": "veja-me"},
		{"from": "observe", "text": "[url=bapotube]https://bapotube.com/watch?v=xX_r31n4m3[/url]", "is_link": true},
	],
}

func _ready():
	super._ready()
	chat_history.bbcode_enabled = true
	chat_history.meta_clicked.connect(_on_link_clicked)
	chat_history.mouse_filter = Control.MOUSE_FILTER_STOP

	for contact_name in CONVERSATIONS.keys():
		var btn = Button.new()
		btn.text = contact_name
		btn.custom_minimum_size = Vector2(0, 72)
		btn.add_theme_font_size_override("font_size", 32)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_open_conversation.bind(contact_name))
		contacts_list.add_child(btn)

func _open_conversation(contact_name: String):
	contact_name_label.text = contact_name
	chat_history.clear()
	
	for msg in CONVERSATIONS[contact_name]:
		var is_link = msg.get("is_link", false)
		var from = msg["from"]
		var text = msg["text"]
		
		if is_link:
			chat_history.append_text("[color=blue]" + text + "[/color]\n\n")
		elif from == "eu":
			chat_history.append_text("[right][color=#aaaaaa]você[/color]\n" + text + "[/right]\n\n")
		else:
			chat_history.append_text("[color=#aaaaaa]" + from + "[/color]\n" + text + "\n\n")

func _on_link_clicked(_meta):
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	GameEvents.subtitle_requested.emit("Você", "Um link..?", 3.5)
	if pc:
		pc.open_window(
			preload("res://scenes/interactables/computer/bapotube_window.tscn"),
			"BapoTube",
			Vector2(-1, -1)
		)
