extends CanvasLayer

@onready var text_label = $Control/PanelContainer/MarginContainer/RichTextLabel

func _ready() -> void:
	self.hide()
	GameEvents.subtitle_requested.connect(_on_subtitle_requested)

func change_text(new_text: String):
	text_label.text = new_text
