extends Interactable

var doc_id: String = "king"
@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	_id = "Document " + doc_id

func interact(_interactor: Node3D):
	if (is_interactable):		
		GameEvents.document_UI_requested.emit(doc_id)
		GameEvents.player_state_changed.emit(GameEvents.player_states.doc_ui)
		play_sfx()

func set_image(new_textura: Texture2D):
	sprite.texture = new_textura

func on_focus_entered():
	if (is_interactable):
		_mesh.material_overlay = _material_overlay
