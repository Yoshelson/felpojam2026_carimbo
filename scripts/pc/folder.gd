extends WindowBase
class_name FolderApp

@onready var grid: GridContainer = $Content/GridContainer

func _ready():
	super._ready()

func add_file(app_scene: PackedScene, app_name: String, icon_texture: Texture2D):
	var icon_scene = preload("res://scenes/interactables/computer/desktop_app_icons.tscn")
	var icon = icon_scene.instantiate() as DesktopAppIcon
	
	grid.add_child(icon)
	icon.setup(app_scene, app_name, icon_texture, Color.BLACK)
