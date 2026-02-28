extends Node3D

@export var level_music: AudioStream
var carimbo_preto = load("res://resources/stamps/BlackStamp.tres")

func _ready() -> void:
	MusicManager.crossfade_to(level_music, 2)
	GameEvents.add_item_to_inventory.emit(carimbo_preto)
