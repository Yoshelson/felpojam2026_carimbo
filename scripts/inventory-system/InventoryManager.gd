extends Node

var _documents_inventory: Dictionary[String, DocumentState]
var _stamp_inventory: Array[String]

signal doc_inventory_changed(id: String)
signal stamp_inventory_changed

func add_document(document_data:DocumentData):
	var doc_id = document_data.id
	if !(_documents_inventory.has(doc_id)):
		var new_doc_state = DocumentState.new(Vector3(0,0,0), document_data)
		_documents_inventory[doc_id] = new_doc_state
		emit_signal("doc_inventory_changed", doc_id)
	else:
		push_warning("Documento já adicionado: ", doc_id)

func add_stamp_color(stamp_name:String):
	if !(_stamp_inventory.has(stamp_name)):
		_stamp_inventory.push_back(stamp_name)
		_stamp_inventory.sort()
		emit_signal("stamp_inventory_changed")
	else:
		push_warning("Carimbo já adicionado: ", stamp_name)

#Terminar após resolver a situação dos carimbos
#garantir failproof de cor minuscula
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

# Questao do Save
