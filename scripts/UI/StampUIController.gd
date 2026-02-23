extends Control

@onready var _button_scene: PackedScene = preload("res://scenes/UI/StampButton.tscn")
@onready var _stamps_wrapper = $Stamp_Wrapper
@onready var _stamps_margin = $Stamp_Wrapper/MarginContainer
@onready var _stamps_container = $Stamp_Wrapper/MarginContainer/Background/MarginContainer/Stamps
signal stamp_pressed(color: String)

var _show_position: Vector2
var _hide_position: Vector2

var _anim_duration: float = 0.5

func _ready() -> void:
	self.hide()
	InventoryManager.stamp_inventory_changed.connect(_att_stamp_colors)
	_recalculate_positions()

#Essa funcao impede que o scroll e o clique passem para outros nodes quando essa
#tela da UI esta ativa
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		accept_event()

func setup_UI():
	self.show()
	var target_y = _show_position
	await _animate_UI(target_y).finished

func disable_UI():
	var target_y = _hide_position
	await _animate_UI(target_y).finished
	self.hide()

func _att_stamp_colors():
	var stamps = InventoryManager.get_all_stamp_colors()
	#Deleta todos as tintas ja mostradas, isso para respeitar a ordem que vem do
	#InventoryManager
	for child in _stamps_container.get_children():
		child.queue_free()
	
	for stamp_data in stamps:
		_instantiate_btn(stamp_data)
	
	#Esperando 2 frames para a UI do godot atualizar o tamanho (para evitar bugs
	#de redimensionamento, oq dessincroniza a imagem da real posicao
	await get_tree().process_frame
	await get_tree().process_frame
	_stamps_wrapper.size = _stamps_margin.get_combined_minimum_size()
	_recalculate_positions()

#A funcao retorna o Tween para que outras funções só terminem de executar após o 
#return dela
func _animate_UI(target_pos: Vector2) -> Tween:
	var tween = create_tween()

	tween.tween_property(_stamps_wrapper, "position", target_pos, _anim_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
				
	return tween

func _instantiate_btn(stamp_data: StampData):
	var btn_scene = _button_scene.instantiate()
	_stamps_container.add_child(btn_scene)
	
	btn_scene.get_node("Stamp Button").texture_normal = stamp_data.image
	#lembrar dessa funcao depois, ela eh bem interessante pra usar, o bind eh 
	#um recurso que anexa uma variavel a quando uma funcao for chamada
	btn_scene.get_node("Stamp Button").pressed.connect(_on_stamp_pressed.bind(stamp_data.name))

func _on_stamp_pressed(stamp_id: String):
	emit_signal("stamp_pressed", stamp_id)
	disable_UI()

func _recalculate_positions():	
	var fixed_position_x = (get_viewport_rect().size.x/2) - (_stamps_wrapper.size.x/2)
	var show_position_y = get_viewport_rect().size.y - _stamps_wrapper.size.y
	var hide_position_y = get_viewport_rect().size.y
	_show_position = Vector2 (fixed_position_x, show_position_y)
	_hide_position = Vector2 (fixed_position_x, hide_position_y)
	_stamps_wrapper.position = _hide_position

func _on_return_btn_pressed() -> void:
	disable_UI()
