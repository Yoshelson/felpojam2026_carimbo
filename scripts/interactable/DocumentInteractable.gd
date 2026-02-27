extends Interactable
class_name DocumentInteractable

var _doc_id: String
@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	_id = "Document " + _doc_id

func interact(_interactor: Node3D):
	if (is_interactable):		
		GameEvents.document_UI_requested.emit(_doc_id)
		GameEvents.player_state_changed.emit(GameEvents.player_states.doc_ui)
		play_sfx()

func set_id(doc_id: String):
	_doc_id = doc_id

func set_image(new_texture: Texture2D):
	sprite.texture = new_texture
