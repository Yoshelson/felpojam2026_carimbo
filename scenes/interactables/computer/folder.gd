extends WindowBase
class_name FolderApp

@onready var grid = $Content/GridContainer

func _ready():
	super._ready()

func add_file(icon_texture, file_name, callback):
	var btn = Button.new()
	btn.text = file_name
	btn.icon = icon_texture
	btn.expand_icon = true
	btn.custom_minimum_size = Vector2(72, 72)
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	
	btn.pressed.connect(callback)
	
	grid.add_child(btn)
