extends WindowBase
class_name VideoPlayerApp

@onready var video: VideoStreamPlayer = $Content/VideoStreamPlayer
@onready var play_button: Button = $Content/Panel/PlayPause
@onready var stop_button: Button = $Content/Panel/Stop
@onready var volume_slider: HSlider = $Content/Panel/Volume
@onready var progress_bar: HSlider = $Content/Progress

var is_seeking := false
var video_length := 0.0

func _ready():
	super._ready()

	play_button.pressed.connect(_on_play_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

	progress_bar.drag_started.connect(_on_seek_start)
	progress_bar.drag_ended.connect(_on_seek_end)

	video.finished.connect(_on_video_finished)

	set_process(true)


func load_video(stream: VideoStream):
	video.stream = stream
	progress_bar.value = 0

	# Força o vídeo a calcular duração corretamente
	video.play()
	await get_tree().process_frame
	video.paused = true

	video_length = video.get_stream_length()

	if video_length <= 0:
		video_length = 1.0  # evita divisão por zero

	progress_bar.max_value = video_length


func _process(_delta):
	if video.stream and video.is_playing() and not video.paused and not is_seeking:
		progress_bar.value = video.stream_position


func _on_play_pressed():
	if not video.stream:
		return

	# Se terminou, reinicia
	if video.stream_position >= video_length:
		video.stream_position = 0

	if video.is_playing() and not video.paused:
		video.paused = true
		play_button.text = "Play"
	else:
		video.play()
		video.paused = false
		play_button.text = "Pause"


func _on_stop_pressed():
	if not video.stream:
		return

	video.stop()
	video.stream_position = 0
	progress_bar.value = 0
	play_button.text = "Play"


func _on_volume_changed(value):
	video.volume_db = value


func _on_seek_start():
	is_seeking = true


func _on_seek_end(_changed):
	if not video.stream:
		return

	video.stream_position = progress_bar.value
	is_seeking = false


func _on_video_finished():
	play_button.text = "Play"
	progress_bar.value = video_length
