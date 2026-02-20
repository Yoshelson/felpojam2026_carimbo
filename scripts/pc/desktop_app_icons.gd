extends Control
class_name DesktopAppIcon

@export var app_scene: PackedScene
@export var app_name: String
@export var icon_texture: Texture2D

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Name

func _ready():
	if icon_texture:
		icon.texture = icon_texture
	label.text = app_name
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.double_click:

		var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
		if pc and app_scene:
			pc.open_window(app_scene, app_name)
