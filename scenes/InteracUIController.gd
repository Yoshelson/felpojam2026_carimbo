extends CanvasLayer

@onready var _eye = $Control/TextureRect
@onready var _prompt_label = $Control/Label
@onready var _player: Player = $"../../.."
var _actual_tween: Tween = null

#Variaveis para Animacao

func _ready() -> void:
	_player.focus_changed.connect(_on_player_focus_changed)
	_hide_UI()

func _on_player_focus_changed(prompt_text: String) -> void:
	if prompt_text == "":
		_hide_UI()
	else:
		_show_UI(prompt_text)
		await _actual_tween.finished
		_pulse_anim()

func _show_UI(prompt_text: String):
	var key_name = "E"
	# Monta a string no formato: [E] prompt do Interectable
	_prompt_label.text = "[" + key_name + "] " + prompt_text
	_prompt_label.show() 
	_eye.show()
	_show_anim()

func _hide_UI():
	_prompt_label.hide()
	_eye.hide()
	_prompt_label.modulate.a = 0
	_eye.modulate.a = 0
	
func _show_anim():
	#Elimina a outra animacao caso ela esteja em andamento para evitar efeitos 
	#estranhos
	if _actual_tween:
		_actual_tween.kill()
	
	_actual_tween = create_tween()
	
	_actual_tween.tween_property(_eye, "modulate:a", 0.8, 0.3)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_actual_tween.parallel().tween_property(_prompt_label, "modulate:a", 1, 0.3)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _pulse_anim():
	#Elimina a outra animacao caso ela esteja em andamento para evitar efeitos 
	#estranhos
	if _actual_tween:
		_actual_tween.kill()
	
	_actual_tween = create_tween()
	_actual_tween.set_loops()

	_actual_tween.tween_property(_eye, "modulate:a", 0.4, 0.75)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_actual_tween.parallel().tween_property(_prompt_label, "modulate:a", 0.5, 0.75)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	_actual_tween.tween_property(_eye, "modulate:a", 0.8, 0.75)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_actual_tween.parallel().tween_property(_prompt_label, "modulate:a", 1, 0.75)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
