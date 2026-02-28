extends Resource

class_name StampData

#ui_pos diz a UI qual a posicao dele na ordem dos carimbos do jogo
@export var ui_pos: int
@export var name: String
@export var image: Texture2D
@export var hover: Texture2D
@export var pressed: Texture2D

static func sort_ascending(a: StampData, b: StampData):
	if (a.ui_pos < b.ui_pos):
		return true
	return false
