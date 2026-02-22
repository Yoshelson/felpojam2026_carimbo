extends Control
class_name WindowBase

@onready var top_bar: Control = $TopBar
@onready var title_label: Label = $TopBar/TitleLabel
@onready var close_button: Button = $TopBar/Close
@onready var content_container: Control = $Content
@onready var minimize_button: Button = $TopBar/Minimize

@export var window_icon: Texture2D


var dragging := false
var drag_offset := Vector2.ZERO

signal minimized(window)

var is_minimized := false

func minimize():
	is_minimized = true
	visible = false
	emit_signal("minimized", self)

func restore():
	is_minimized = false
	visible = true

	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if pc:
		pc.request_focus(self)


func _ready():
	close_button.pressed.connect(_on_close_pressed)
	minimize_button.pressed.connect(minimize)
	top_bar.gui_input.connect(_on_top_bar_gui_input)
	mouse_filter = Control.MOUSE_FILTER_PASS


func set_title(text: String):
	title_label.text = text


func _gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
		if pc:
			pc.request_focus(self)


func _on_close_pressed():
	queue_free()


func _on_top_bar_gui_input(event):

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			dragging = true
			drag_offset = event.position
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:

		position += event.relative

		var viewport_size = get_viewport().size
		var taskbar_height := 80.0

		position.x = clamp(position.x, 0, viewport_size.x - size.x)
		position.y = clamp(position.y, 0, viewport_size.y - size.y - taskbar_height)
