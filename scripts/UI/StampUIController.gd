extends MarginContainer

@onready var _button_scene: PackedScene = load("res://scenes/UI/StampButton.tscn")
@onready var _stamps_container = $Background/MarginContainer/Stamps
signal stamp_pressed(color: String)

var _show_position_y: float
var _hide_position_y: float

var _is_show = false

func _ready() -> void:
	InventoryManager.stamp_inventory_changed.connect(_att_stamp_colors)
	_show_position_y = self.position.y
	_hide_position_y = self.position.y + self.size.y

func _att_stamp_colors():
	var stamps = InventoryManager.get_all_stamp_colors()
	#Deleta todos as tintas ja mostradas, isso para respeitar a ordem que vem do
	#InventoryManager
	for child in _stamps_container.get_children():
		child.queue_free()
	
	for stamp_data in stamps:
		_instantiate_btn(stamp_data)
	
	await get_tree().process_frame
	if _is_show:
		_show_position_y = self.position.y
		_hide_position_y = self.position.y + self.size.y
	else:
		_hide_position_y = self.position.y
		_show_position_y = self.position.y - self.size.y
	
func toggle_UI():
	var target_y: float
	
	if _is_show:
		target_y = _hide_position_y
	else:
		target_y = _show_position_y
		
	_animate_UI(target_y)
	_is_show = !_is_show

func _animate_UI(target_pos: float):
	var tween = create_tween()

	tween.tween_property(self, "position:y", target_pos, 0.3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func _instantiate_btn(stamp_data: StampData):
	var btn_scene = _button_scene.instantiate()
	_stamps_container.add_child(btn_scene)
	
	btn_scene.get_node("Stamp Button").texture_normal = stamp_data.image
	#lembrar dessa funcao depois, ela eh bem interessante pra usar, o bind eh 
	#um recurso que anexa uma variavel a quando uma funcao for chamada
	btn_scene.get_node("Stamp Button").pressed.connect(_on_stamp_pressed.bind(stamp_data.name))

func _on_stamp_pressed(stamp_id: String):
	emit_signal("stamp_pressed", stamp_id)
