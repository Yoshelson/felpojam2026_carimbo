extends Control

@export var _text_label: RichTextLabel

func _ready() -> void:
	if _text_label == null:
		push_error("Error: RichTextLabel Node não definido na TranscriptUI")
	disable_UI()
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		accept_event()

func setup_UI():
	self.show()

func disable_UI():
	self.hide()

func att_transcription(text: String):
	_text_label.text = text

func _on_return_btn_pressed() -> void:
	disable_UI()
