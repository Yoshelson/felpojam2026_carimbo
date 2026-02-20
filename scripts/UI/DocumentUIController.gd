extends CanvasLayer

@onready var document_container = $"Document Container"
@onready var document_image = $"Document Container/Document Image"
var min_zoom: float = 0.5
var max_zoom: float = 3
var step_zoom: float = 0.1
var zoom_smoothness: float = 10

var _target_zoom: float = 1
var _actual_zoom: float = 1
var _is_panning: bool = false
var _target_pos: Vector2

var _actual_doc_id: String = ""
var _actual_transcripted_text: String = ""

func _ready() -> void:
	_disable_UI()
	#setup_UI("king")
	InventoryManager.doc_inventory_changed.connect(_att_doc_UI)

func _process(delta: float) -> void:
	_actual_zoom = lerp(_actual_zoom, _target_zoom, zoom_smoothness * delta)
	document_image.scale = Vector2(_actual_zoom, _actual_zoom)
	
	_pos_in_limits()
	document_image.position = _target_pos

func setup_UI(doc_id: String):
	var document = InventoryManager.get_doc(doc_id)
	if document:
		document_image.texture = document._actual_image
		_actual_doc_id = doc_id
		_actual_transcripted_text = document._document_data.transcripted_text
		await get_tree().process_frame
		_center_doc_pivot()
		_target_zoom = 1
		_actual_zoom = 1
		_is_panning = false
		visible = true
	else:
		print("ERROR: Id de Documento enviado para UI não está no inventário")
		
func _att_doc_UI(doc_id: String):
	if _actual_doc_id == doc_id:
		var document = InventoryManager.get_doc(doc_id)
		if document:
			document_image.texture = document._actual_image
			_actual_transcripted_text = document._document_data.transcripted_text
		else:
			push_error("ERROR: Id de Documento enviado para UI não está no inventário")

func _disable_UI():
	visible = false

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if (_target_zoom + step_zoom) > max_zoom:
				_target_zoom = max_zoom
			else:
				_target_zoom = _target_zoom + step_zoom
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if (_target_zoom - step_zoom) < min_zoom:
				_target_zoom = min_zoom
			else:
				_target_zoom = _target_zoom - step_zoom
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_is_panning = event.pressed
	if event is InputEventMouseMotion and _is_panning:
		_target_pos += event.relative
	
func _pos_in_limits():
	var container_size = document_container.size
	var document_size = document_image.size * _actual_zoom
	
	#Isso é importante por que pq o godot deixa imagens com zoom ainda com seus
	#valores como scale=1.0. Então, temos que lembrar a posicao da imagem (pivot)
	#e usar o half_doc_size para calcular a distancia para esse pivot
	var half_doc_size = Vector2(document_size.x/2.0, document_size.y/2.0)
	var pivot = document_image.pivot_offset
	
	var margin_doc_x= document_size.x/4
	var margin_doc_y = document_size.y/4
	var margins_doc = Vector2 (margin_doc_x,margin_doc_y)
	
	#Demorei um bom tempo para entender, mas aparentemente, quando o godot troca
	#o pivot_point, o programa não muda a posicao absoluta para ele. Logo,
	#para fazer os calculos das margens, é necessário procurar o limite, que é
	#quando a posição na tela iguala a borda do documento + margem daquela região
	#OBS: A borda do documento é mais complexa pq existe zoom (vou deixar ela
	#parenteses no calculo), então temos que calcula-la pelo pivot central e 
	#metade do tamanho do doc atual
	
	var min_limit_x = margins_doc.x - (half_doc_size.x + pivot.x)
	var max_limit_x = container_size.x - margins_doc.x + (half_doc_size.x - pivot.x)
	var min_limit_y = margins_doc.y - (half_doc_size.y + pivot.y)
	var max_limit_y = container_size.y - margins_doc.y + (half_doc_size.y - pivot.y)
	
	_target_pos.x = maxf(min_limit_x, _target_pos.x)
	_target_pos.x = minf(max_limit_x, _target_pos.x)
	_target_pos.y = maxf(min_limit_y, _target_pos.y)
	_target_pos.y = minf(max_limit_y, _target_pos.y)
	
func _center_doc_pivot():
	var container_size = document_container.size
	var document_size = document_image.size
	document_image.pivot_offset = document_size/2
	
	document_image.position = (container_size/2) - (document_size / 2)
	_target_pos = document_image.position

func _on_return_btn_pressed() -> void:
	_disable_UI()

func _on_stamp_btn_pressed() -> void:
	#open color
	pass

func _on_transcription_btn_pressed() -> void:
	#transcription code
	pass 
