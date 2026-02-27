extends Node

var _documents_inventory: Dictionary[String, DocumentState]
var _stamp_inventory: Array[StampData]

signal doc_inventory_changed(id: String)
signal stamp_inventory_changed()

func _ready() -> void:
	GameEvents.add_item_to_inventory.connect(handle_new_resource)

func handle_new_resource(new_item: Resource):
	if new_item is DocumentData:
		add_document(new_item)
	elif new_item is StampData:
		add_stamp_color(new_item)
	else:
		push_warning("O item adicionado é de um tipo não existente: ", new_item)

func add_document(document_data: DocumentData):
	var doc_id = document_data.id
	if !(_documents_inventory.has(doc_id)):
		var new_doc_state = DocumentState.new(Vector3(0,0,0), document_data)
		_documents_inventory[doc_id] = new_doc_state
		emit_signal("doc_inventory_changed", doc_id)
	else:
		push_warning("Documento já adicionado: ", doc_id)

func add_stamp_color(stamp_data: StampData):
	if !(_stamp_inventory.has(stamp_data)):
		_stamp_inventory.push_back(stamp_data)
		_stamp_inventory.sort_custom(Callable(StampData, "sort_ascending"))
		emit_signal("stamp_inventory_changed")
	else:
		push_warning("Carimbo já adicionado: ", stamp_data.name)

func stamp_doc(doc_id: String, new_color: String):
	if _documents_inventory.has(doc_id):
		var stamped_doc = _documents_inventory[doc_id]
		var img_changed = stamped_doc.add_new_color(new_color)
		if img_changed:
			emit_signal("doc_inventory_changed", doc_id)
	
func get_all_docs() -> Dictionary[String, DocumentState]:
	return _documents_inventory

func get_doc(doc_id: String) -> DocumentState:
	if _documents_inventory.has(doc_id):
		return _documents_inventory[doc_id]
	return null

func get_all_stamp_colors() -> Array[StampData]:
	return _stamp_inventory
