extends Node

var number = 0;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			#Test ADD e Signal p/ UI
			var load_doc1 = load("res://resources/documents/test_doc.tres")
			var load_doc2 = load("res://resources/documents/test_doc_2.tres")
			var load_doc3 = load("res://resources/documents/test_doc_3.tres")
			InventoryManager.add_document(load_doc1)
			InventoryManager.add_document(load_doc2)
			InventoryManager.add_document(load_doc3)
			InventoryManager.add_document(load_doc1)
			InventoryManager.add_document(load_doc2)
			InventoryManager.add_document(load_doc3)
			
			InventoryManager.add_stamp("Blue")
			InventoryManager.add_stamp("Red")
			InventoryManager.add_stamp("Blue")
			InventoryManager.add_stamp("Red")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			#Testar Signal e GetDoc e UI
			if (number < 1):
				var document_UI = $".."
				document_UI.setup_UI("king")
			elif (number == 4):
				InventoryManager.stamp_doc("king", "Blue")
			number+=1
			
