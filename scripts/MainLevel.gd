extends Node3D

@export var level_music: AudioStream

func _ready() -> void:
	MusicManager.crossfade_to(level_music, 2)
