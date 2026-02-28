extends WindowBase
class_name ZipLockApp

@onready var input: LineEdit = $Content/LineEdit
@onready var error_label: Label = $Content/Error
@onready var open_button: Button = $Content/Open

var correct_password := "OURO"

func _ready():
	super._ready()
	open_button.pressed.connect(_try_open)
	input.text_submitted.connect(func(_t): _try_open())
	
	input.text_changed.connect(func(t):
		input.text = t.to_upper()
		input.caret_column = input.text.length()
	)
	

func set_password(password: String):
	correct_password = password

func _try_open():
	if input.text.strip_edges().to_upper() == correct_password:
		_open_reward()
	else:
		error_label.text = "Senha incorreta."

func _open_reward():
	var pc: PCControl = get_tree().get_first_node_in_group("pc_control")
	var scene = preload("res://scenes/interactables/computer/image_viewer_reward.tscn")
	var jorge = load("res://resources/documents/Autopsia.tres")
	pc.open_window(scene, "Recompensa", Vector2(-1, -1))
	GameEvents.subtitle_requested.emit("Você:", "Esse [color=yellow]símbolo[/color] me é famíliar", 3)
	
	GameEvents.add_item_to_inventory.emit(jorge)
	
	queue_free()
