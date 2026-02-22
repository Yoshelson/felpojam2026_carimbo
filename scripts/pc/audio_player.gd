extends WindowBase

@export var audio_stream : AudioStream

@onready var player : AudioStreamPlayer = $Content/AudioStreamPlayer
@onready var play_button : Button = $Content/HBoxContainer/PlayPause
@onready var time_slider : HSlider = $Content/HBoxContainer/TimeSlider
@onready var volume_slider : HSlider = $Content/HBoxContainer/VolumeSlider

var is_dragging := false


func _ready(): 
	super._ready()
	player.stream = audio_stream
	
	# Configurar volume
	volume_slider.min_value = -40
	volume_slider.max_value = 0
	volume_slider.value = 0
	
	# Configurar barra de tempo
	time_slider.min_value = 0
	time_slider.max_value = 1
	time_slider.step = 0.001
	
	play_button.pressed.connect(_on_play_pause)
	time_slider.drag_started.connect(func(): is_dragging = true)
	time_slider.drag_ended.connect(func(_value_changed): is_dragging = false)
	time_slider.value_changed.connect(_on_time_slider_changed)
	volume_slider.value_changed.connect(_on_volume_changed)
	
	player.finished.connect(_on_audio_finished)
	

func _on_audio_finished():
	play_button.text = "Play"
	paused_position = 0.0
	time_slider.value = 0

func _process(_delta):
	if player.playing and not is_dragging:
		var progress = player.get_playback_position() / player.stream.get_length()
		time_slider.value = progress


var paused_position := 0.0

func _on_play_pause():
	if player.playing:
		paused_position = player.get_playback_position()
		player.stop()
		play_button.text = "Play"
	else:
		player.play(paused_position)
		play_button.text = "Pause"


func _on_time_slider_changed(value):
	if is_dragging and player.stream:
		var new_pos = value * player.stream.get_length()
		player.seek(new_pos)



func _on_volume_changed(value):
	player.volume_db = value
