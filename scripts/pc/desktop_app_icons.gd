extends Control
class_name DesktopAppIcon

@export var app_scene: PackedScene
@export var app_name: String = ""
@export var icon_texture: Texture2D
@export var font_color: Color = Color.WHITE

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Name

var hidden_by_gold := false
var permanently_revealed := false

func _ready():
	_update_visual()

func _update_visual():
	if icon and icon_texture:
		icon.texture = icon_texture
	if label:
		label.text = app_name
		label.self_modulate = font_color

func setup(scene: PackedScene, app_title: String, texture: Texture2D, color: Color = Color.WHITE):
	app_scene = scene
	app_name = app_title
	icon_texture = texture
	font_color = color
	_update_visual()

func _gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.double_click:
		var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
		if pc and app_scene and not hidden_by_gold:
			pc.open_window(app_scene, app_name)

func hide_by_gold():
	hidden_by_gold = true
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("hidden_icons")

func reveal():
	if permanently_revealed:
		return
	permanently_revealed = true
	hidden_by_gold = false
	modulate.a = 1.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	remove_from_group("hidden_icons")
