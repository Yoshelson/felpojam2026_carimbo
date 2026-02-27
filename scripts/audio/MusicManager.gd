extends Node

@onready var player_a = $"Player A"
@onready var player_b = $"Player B"

var _active_player: AudioStreamPlayer
var _inactive_player: AudioStreamPlayer

func _ready() -> void:
	_active_player = player_a
	_inactive_player = player_b

func crossfade_to(new_music: AudioStream, crossfade_time: float = 2):
	#Garante que um erro desgracado nao aconteca e a mesma musica volte a rodar 
	#novamente (isso eh mais uma garantia para o futuro do projeto, para a 
	#gamejam eu ACHO que nenhum momento essa linha iria bloquear algo)
	if _active_player.stream == new_music and _active_player.playing:
		return
	
	_inactive_player.stream = new_music
	_inactive_player.volume_db = -80.0
	_inactive_player.play()
	
	#Usa os dois players para transicionar o som de forma agradavel entre eles no
	#tempo determinado pelo usuario
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_active_player, "volume_db", -80.0, crossfade_time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_inactive_player, "volume_db", -15, crossfade_time).set_trans(Tween.TRANS_SINE)
	
	tween.finished.connect(_on_fade_end.bind(_active_player))
	
	var temp = _active_player
	_active_player = _inactive_player
	_inactive_player = temp

func _on_fade_end (player: AudioStreamPlayer) -> void:
	player.stop()
	
func stop_music(fade_out_time: float = 1) -> Tween:
	if !(_active_player.playing):
		return
	
	var tween = create_tween()
	tween.tween_property(_active_player, "volume_db", -80, fade_out_time)
	tween.finished.connect(_on_fade_end.bind(_active_player))
	
	return tween
