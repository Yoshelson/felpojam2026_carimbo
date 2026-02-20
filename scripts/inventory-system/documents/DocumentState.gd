class_name DocumentState

var _frame_pos: Vector3
var _applied_colors: Array[String]
var _actual_image: Texture2D
var _document_data: DocumentData

# Construtor para criar as instancias dos documentos no jogo. Para cria-lo, e
# necessario fazer o calculo de posicao antes
func _init(frame_pos: Vector3, document_data:DocumentData) -> void:
	_frame_pos = frame_pos
	_applied_colors = []
	_actual_image = document_data.base_image
	_document_data = document_data

func add_new_color(new_color: String) -> bool:
	if !(_applied_colors.has(new_color)):
		_applied_colors.push_back(new_color)
		_applied_colors.sort()
		return _check_transition()
	return false

func _check_transition() -> bool:
	for variation in _document_data.variations:
		if (_applied_colors == variation.colors_needed):
			_actual_image = variation.variant_sprite
			return true
	return false
