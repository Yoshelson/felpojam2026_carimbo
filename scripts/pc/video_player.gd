extends WindowBase
class_name VideoPlayerApp

@onready var video: VideoStreamPlayer = $Content/VBox/VideoStreamPlayer
@onready var progress: HSlider = $Content/VBox/Controls/Progress
@onready var time_label: Label = $Content/VBox/Controls/Buttons/TimeLabel
@onready var play_btn: Button = $Content/VBox/Controls/Buttons/PlayPause
@onready var stop_btn: Button = $Content/VBox/Controls/Buttons/Stop
@onready var vol_slider: HSlider = $Content/VBox/Controls/Buttons/Volume

var is_seeking := false

func _ready():
	super._ready()
	play_btn.pressed.connect(_on_play)
	stop_btn.pressed.connect(_on_stop)
	vol_slider.value_changed.connect(func(v): video.volume_db = v)
	progress.drag_started.connect(func(): is_seeking = true)
	progress.drag_ended.connect(_on_seek_end)
	video.finished.connect(_on_finished)

	if video.stream:
		var length = video.get_stream_length()
		time_label.text = "0:00 / " + _fmt(length)
		progress.max_value = length if length > 0 else 1.0
		video.play()
		await get_tree().process_frame
		await get_tree().process_frame
		video.paused = true

func _process(_delta):
	if not video.stream:
		return
	var length = video.get_stream_length()
	if length > 0 and video.is_playing() and not is_seeking:
		progress.max_value = length
		progress.value = video.stream_position
		time_label.text = _fmt(video.stream_position) + " / " + _fmt(length)

func _on_play():
	if not video.stream:
		return
	if video.is_playing():
		video.paused = not video.paused
		play_btn.text = "▐▐" if not video.paused else "▶"
	else:
		video.play()
		play_btn.text = "▐▐"

func _on_stop():
	if not video.stream:
		return
	video.stop()
	progress.value = 0
	time_label.text = "0:00 / " + _fmt(video.get_stream_length())
	play_btn.text = "▶"

func _on_seek_end(_changed):
	if not video.stream:
		return
	var was_playing = video.is_playing()
	video.stop()
	video.play()
	video.stream_position = progress.value
	if not was_playing:
		video.paused = true
		play_btn.text = "▶"
	is_seeking = false

func _on_finished():
	play_btn.text = "▶"
	progress.value = 0

func _fmt(seconds: float) -> String:
	var s = int(seconds)
	return "%d:%02d" % [s / 60, s % 60]
