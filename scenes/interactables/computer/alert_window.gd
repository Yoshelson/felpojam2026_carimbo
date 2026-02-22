extends WindowBase
class_name AlertWindow

@onready var message_label: Label = $Content/Text
@onready var ok_button: Button = $Content/OK

func _ready():
	super._ready()
	ok_button.pressed.connect(_close)

func set_message(text: String):
	message_label.text = text

func _close():
	queue_free()
