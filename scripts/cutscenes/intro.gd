extends Node

@onready var overlay: ColorRect = $"../Overlay"
@onready var audio: AudioStreamPlayer3D = $"../AudioIntro"

@export var som_porta: AudioStream
@export var fade_duration: float = 3.0

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	
	var _player = get_tree().get_first_node_in_group("Player")
	GameEvents.change_player_state(GameEvents.player_states.cinematic_ui)
	
	overlay.color.a = 1.0
	overlay.visible = true
	
	await get_tree().create_timer(1.5).timeout
	
	audio.stream = som_porta
	audio.play()
	
	await get_tree().create_timer(3.5).timeout
	
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, fade_duration)
	await tween.finished
	
	GameManager.set_flag("caixa_inicial_aberta", true)
	
	GameManager.set_flag("has_black_stamp", true)
	GameManager.set_flag("has_ficha_criminal", true)
	GameManager.set_flag("has_fotos_animais", true)
	GameManager.set_flag("has_caixa_carimbo", true)
	
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Ficha_Criminal.tres"))
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Fotos_Animais.tres"))
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/stamps/BlackStamp.tres"))
	
	#
	#GameEvents.dialogue_requested.emit([
	#{speaker = "Você:", text = "Hm... que barulho foi esse?"},
	#{speaker = "[color=cyan]Entregador[/color]", text = "Entrega chegou!"},
	#{speaker = "Você", text = "Melhor ir ver."},
	#])
	#await GameEvents.dialogue_finished
	
	
	#GameEvents.subtitle_requested.emit("Você", "Hm... que barulho foi esse?", 2.0)
	#await get_tree().create_timer(1.0).timeout
	#
	#GameEvents.subtitle_requested.emit("[color=cyan]Entregador[/color]", "Entrega chegou!", 2.0)
	#await get_tree().create_timer(1.0).timeout
	#
	#GameEvents.subtitle_requested.emit("Você", "Melhor ir ver.", 2.5)
	#await get_tree().create_timer(3).timeout
	
	overlay.visible = false
	GameEvents.change_player_state(GameEvents.player_states.walking)
