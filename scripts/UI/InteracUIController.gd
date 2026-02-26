extends CanvasLayer

@onready var _control = $Control
@onready var _dot = $Control/Dot
@onready var _eye = $Control/Eye
@onready var _prompt_label = $Control/Label
var _actual_tween: Tween = null

#Variaveis para Animacao
const _MAX_OPACITY_EYE: float = 0.8
const _MAX_OPACITY_LABEL: float = 1
const _MIN_OPACITY_EYE: float = 0.4
const _MIN_OPACITY_LABEL: float = 0.5

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.focus_changed.connect(_on_player_focus_changed)
	_hide_UI()

func _process(delta: float) -> void:
	#Essa funcao garante que o tooltip de interacao sempre esteja no local certo
	#Quando o mouse esta capturado, o tooltip fica no centro da tela
	#Quando o mouse nao esta, ele usa a posicao do mouse
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		var mouse_pos = get_viewport().get_mouse_position()
		_control.global_position = mouse_pos
	else:
		_control.global_position = get_viewport().get_visible_rect().size / 2.0

func _on_player_focus_changed(prompt_text: String) -> void:
	if prompt_text == "":
		_hide_UI()
	else:
		_show_UI(prompt_text)

func _show_UI(prompt_text: String):
	var key_name = "E"
	# Monta a string no formato: [E] prompt do Interectable
	_prompt_label.text = "[" + key_name + "] " + prompt_text
	
	#Deixa apenas o tooltip pra representa o mouse quando nao estamo em um 
	#estado que deixa-o captured
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	_dot.hide()
	_prompt_label.show() 
	_eye.show()
	
	_show_anim()

func _hide_UI():	
	_prompt_label.hide()
	_eye.hide()
	
	#Redefine o mouse caso tenha sido alterado no show_ui()
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#Impede que o dot apareca quando nao estivermos com o mesmo capturado
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		_dot.show()
	else:
		_dot.hide()
	
	_prompt_label.modulate.a = 0
	_eye.modulate.a = 0
	
	if _actual_tween:
		_actual_tween.kill()
	
func _show_anim():
	#Elimina a outra animacao caso ela esteja em andamento para evitar efeitos 
	#estranhos
	if _actual_tween:
		_actual_tween.kill()
	
	_actual_tween = create_tween()
	
	_actual_tween.tween_property(_eye, "modulate:a", _MAX_OPACITY_EYE, 0.5)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_actual_tween.parallel().tween_property(_prompt_label, "modulate:a", _MAX_OPACITY_LABEL, 0.5)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	_actual_tween.tween_callback(_pulse_anim)

func _pulse_anim():
	#Elimina a outra animacao caso ela esteja em andamento para evitar efeitos 
	#estranhos
	if _actual_tween:
		_actual_tween.kill()
	
	_actual_tween = create_tween()
	_actual_tween.set_loops()

	#Passo 1: Diminuir Opacidade(alpha)
	_actual_tween.tween_property(_eye, "modulate:a",\
	_MIN_OPACITY_EYE, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_actual_tween.parallel().tween_property(_prompt_label, "modulate:a",\
	_MIN_OPACITY_LABEL, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	#Passo 2: Aumentar Opacidade(alpha)
	_actual_tween.tween_property(_eye, "modulate:a",\
	_MAX_OPACITY_EYE, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_actual_tween.parallel().tween_property(_prompt_label, "modulate:a",\
	_MAX_OPACITY_LABEL, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
