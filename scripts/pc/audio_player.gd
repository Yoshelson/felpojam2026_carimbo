extends WindowBase
class_name AudioPlayerApp

@export var audio_stream: AudioStream

@onready var player: AudioStreamPlayer = $Content/VBox/AudioStreamPlayer
@onready var play_btn: Button = $Content/VBox/Controls/Buttons/PlayPause
@onready var time_label: Label = $Content/VBox/Controls/Buttons/TimeLabel
@onready var time_slider: HSlider = $Content/VBox/Controls/TimeSlider
@onready var vol_slider: HSlider = $Content/VBox/Controls/Buttons/Volume

var is_dragging := false
var paused_position := 0.0

func _ready():
	super._ready()
	player.stream = audio_stream
	
	time_slider.min_value = 0.0
	time_slider.max_value = 1.0
	time_slider.step = 0.001
	
	vol_slider.min_value = -40.0
	vol_slider.max_value = 0.0
	vol_slider.value = 0.0
	
	play_btn.pressed.connect(_on_play)
	time_slider.drag_started.connect(func(): is_dragging = true)
	time_slider.drag_ended.connect(func(_v): is_dragging = false)
	time_slider.value_changed.connect(_on_seek)
	vol_slider.value_changed.connect(func(v): player.volume_db = v)
	player.finished.connect(_on_finished)

func _process(_delta):
	if not player.stream:
		return
	var length = player.stream.get_length()
	if player.playing and not is_dragging and length > 0:
		var pos = player.get_playback_position()
		time_slider.value = pos / length
		time_label.text = _fmt(pos) + " / " + _fmt(length)

func _on_play():
	if player.playing:
		paused_position = player.get_playback_position()
		player.stop()
		play_btn.text = "▶"
	else:
		player.play(paused_position)
		play_btn.text = "▐▐"

func _on_seek(value: float):
	if is_dragging and player.stream:
		player.seek(value * player.stream.get_length())

func _on_finished():
	play_btn.text = "▶"
	paused_position = 0.0
	time_slider.value = 0.0
	var length = player.stream.get_length() if player.stream else 0.0
	time_label.text = "0:00 / " + _fmt(length)

func _fmt(seconds: float) -> String:
	var s = int(seconds)
	return "%d:%02d" % [s / 60, s % 60]
