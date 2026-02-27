extends TeleportInteractable

var board_docs: Dictionary[String, DocumentInteractable] = {}
@onready var docs_container = $DocumentsContainer

func _ready() -> void:
	InventoryManager.doc_inventory_changed.connect(_on_inventory_changed)
	original_prompt = prompt_message

func _on_inventory_changed(doc_id: String):
	if board_docs.has(doc_id):
		var document = InventoryManager.get_doc(doc_id)
		board_docs[doc_id].set_image(document._actual_image)
	else:
		add_doc(doc_id)
	
func add_doc(doc_id: String):
	var document = InventoryManager.get_doc(doc_id)
	var frame_pos = document._document_data.board_pos
	var texture = document._actual_image
	var package_scene = document._document_data.prefab_scene
	
	var new_doc: DocumentInteractable = package_scene.instantiate()
	docs_container.add_child(new_doc)
	
	new_doc.set_image(texture)
	new_doc.set_id(doc_id)
	new_doc.position = frame_pos
	
	board_docs[doc_id] = new_doc
