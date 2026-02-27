class_name DocumentState

var _frame_pos: Vector3
var _applied_colors: Array[String]
var _actual_image: Texture2D
var _actual_transcription: String
var _document_data: DocumentData

# Construtor para criar as instancias dos documentos no jogo. Para cria-lo, e
# necessario fazer o calculo de posicao antes
func _init(frame_pos: Vector3, document_data:DocumentData) -> void:
	_frame_pos = document_data.board_pos
	_applied_colors = []
	_actual_image = document_data.base_image
	_actual_transcription = document_data.base_transcripted_text
	_document_data = document_data
	_document_data.variations.sort_custom(_sort_descending)
	
static func _sort_descending(a: DocColorCombination, b: DocColorCombination):
	if (a.colors_needed.size() > b.colors_needed.size()):
		return true
	return false
	
func add_new_color(new_color: String) -> bool:
	if !(_applied_colors.has(new_color)):
		if (_document_data.requires_color_order):
			if (_check_color_order(new_color)):
				_applied_colors.push_back(new_color)
				return _check_transition()
		else:
			_applied_colors.push_back(new_color)
			return _check_transition()
	return false

func _check_color_order(new_color: String) -> bool:
	#Como existe apenas uma ordem correta e o array de variations esta em ordem
	#decrescente, a sua primeira ocorrencia eh a correta
	var new_color_index = _applied_colors.size()
	var final_order = _document_data.variations[0].colors_needed
	
	#Garante que nao ocorra out-of-bounds e verifica se a prox cor eh a requerida
	if (final_order.size() > new_color_index):
		if (final_order[new_color_index] == new_color):
			return true
	return false

func _check_transition() -> bool:
	for variation in _document_data.variations:
		if (_has_required_colors(variation.colors_needed)):
			_apply_transition(variation)
			return true
	return false

func _has_required_colors (colors_needed: Array[String]) -> bool:
	for color in colors_needed:
		if !(_applied_colors.has(color)):
			return false
	return true
	
func _apply_transition (variation: DocColorCombination):
	_actual_image = variation.variant_sprite
	_actual_transcription = variation.variant_transcription
