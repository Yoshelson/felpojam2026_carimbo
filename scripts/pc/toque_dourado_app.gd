extends WindowBase
class_name ToqueDeMidasApp

@onready var lens: Control = $Content/Lens


func _ready():
	super._ready()


func _process(_delta):
	reveal_hidden_icons()


# revela ícones escondidos
func reveal_hidden_icons():
	var lens_rect = lens.get_global_rect()
	
	for icon in get_tree().get_nodes_in_group("hidden_icons"):
		if icon is DesktopAppIcon:
			if lens_rect.intersects(icon.get_global_rect()):
				icon.reveal()
