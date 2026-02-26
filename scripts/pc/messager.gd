extends WindowBase
class_name MessengerApp

@onready var contacts_list = $Content/HBoxContainer/ContactsPanel/ContactsMargin/ContactsList
@onready var contact_name_label = $Content/HBoxContainer/ChatPanel/ChatMargin/ChatVBox/ContactNameLabel
@onready var chat_history = $Content/HBoxContainer/ChatPanel/ChatMargin/ChatVBox/ChatHistory

const CONVERSATIONS = {
	"Felpo": [
		{"from": "Felpo",  "text": "cara você viu aquele vídeo de lontra de ontem"},
		{"from": "Felpo",  "text": "a lontra abraçou o filhote dela e eu chorei"},
		{"from": "eu",     "text": "kkkkkk que isso"},
		{"from": "Felpo",  "text": "não to brincando, lontras são o animal mais fofo da terra"},
		{"from": "eu",     "text": "concordo honestamente"},
		{"from": "Felpo",  "text": "pesquisei e elas ficam de mãos dadas pra não se perder no rio"},
		{"from": "eu",     "text": "para eu não aguento"},
	],
	"aureli0_934": [
		{"from": "aureli0_934", "text": "oi sumida"},
		{"from": "eu",          "text": "oi! tava ocupada essa semana"},
		{"from": "aureli0_934", "text": "tudo bem por aí?"},
		{"from": "eu",          "text": "mais ou menos, o trabalho tá pesado"},
		{"from": "aureli0_934", "text": "imagina, aqui igual"},
		{"from": "aureli0_934", "text": "pelo menos o fim de semana tá chegando"},
		{"from": "eu",          "text": "é verdade, vou sair um pouco pelo menos"},
		{"from": "aureli0_934", "text": "boa, você precisa"},
	],
	"maria": [
		{"from": "maria", "text": "veja-me"},
		{"from": "maria", "text": "[url=bapotube]https://bapotube.com/watch?v=xX_r31n4m3[/url]", "is_link": true},
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
	if pc:
		pc.open_window(
			preload("res://scenes/interactables/computer/bapotube_window.tscn"),
			"BapoTube",
			Vector2(-1, -1)
		)
