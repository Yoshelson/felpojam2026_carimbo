extends Node

@onready var overlay: ColorRect = $"../Overlay"

@export var fade_duration: float = 3.0

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	
	var _player = get_tree().get_first_node_in_group("Player")
	GameEvents.change_player_state(GameEvents.player_states.cinematic_ui)
	
	overlay.color.a = 1.0
	overlay.visible = true
	
	await get_tree().create_timer(3).timeout
	
	
	GameEvents.dialogue_requested.emit([
	{speaker = "Você:", text = "Midas e Monique... Vocês são patéticos, que péssimo esconderijio, eu faria bem melhor"},
	{speaker = "Você", text = "Eu sei que você é o assassino e agora, pela sua incompetência tudo virá à tona"},
	])
	await GameEvents.dialogue_finished
	
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, fade_duration)
	await tween.finished
	
	#GameManager.set_flag("caixa_inicial_aberta", true)
	
	#GameManager.set_flag("has_black_stamp", true)
	#GameManager.set_flag("has_ficha_criminal", true)
	#GameManager.set_flag("has_fotos_animais", true)
	#GameManager.set_flag("has_caixa_carimbo", true)
	#
	#GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Ficha_Criminal.tres"))
	#GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Fotos.tres"))
	#GameEvents.emit_signal("add_item_to_inventory", load("res://resources/stamps/BlackStamp.tres"))
	
	
	
	
	overlay.visible = false
	GameEvents.change_player_state(GameEvents.player_states.walking)
