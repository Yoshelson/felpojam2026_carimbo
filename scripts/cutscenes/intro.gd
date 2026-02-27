extends Node

@onready var overlay: ColorRect = $"../Overlay"
@onready var audio: AudioStreamPlayer3D = $"../AudioIntro"

@export var som_porta: AudioStream
@export var fade_duration: float = 3.0

func _ready():
	var player = get_tree().get_first_node_in_group("Player")
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
	
	GameEvents.subtitle_requested.emit("Você", "Hm... que barulho foi esse?", 2.0)
	await get_tree().create_timer(2.0).timeout
	
	GameEvents.subtitle_requested.emit("[color=cyan]Entregador[/color]", "Entrega chegou!", 2.0)
	await get_tree().create_timer(2.0).timeout
	
	GameEvents.subtitle_requested.emit("Você", "Melhor ir ver.", 2.5)
	await get_tree().create_timer(3).timeout
	
	overlay.visible = false
	GameEvents.change_player_state(GameEvents.player_states.walking)
