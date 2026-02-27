extends Node

var number = 0;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			#Test ADD e Signal p/ UI
			var load_doc1 = load("res://resources/documents/Autopsia.tres")
			var load_doc2 = load("res://resources/documents/test_doc_2.tres")
			var load_doc3 = load("res://resources/documents/test_doc_3.tres")
			InventoryManager.add_document(load_doc1)
			InventoryManager.add_document(load_doc2)
			InventoryManager.add_document(load_doc3)

			var load_stamp1 = load("res://resources/stamps/BlackStamp.tres")
			var load_stamp2 = load("res://resources/stamps/WhiteStamp.tres")
			var load_stamp3 = load("res://resources/stamps/GreenStamp.tres")
			var load_stamp4 = load("res://resources/stamps/BlueStamp.tres")
			var load_stamp5 = load("res://resources/stamps/YellowStamp.tres")
			InventoryManager.add_stamp_color(load_stamp1)
			InventoryManager.add_stamp_color(load_stamp2)
			InventoryManager.add_stamp_color(load_stamp3)
			InventoryManager.add_stamp_color(load_stamp4)
			InventoryManager.add_stamp_color(load_stamp5)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			#Testar Signal e GetDoc e UI
			var document_UI = $".."
			document_UI.setup_UI("autopsia")
		
