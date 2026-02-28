extends Node

var number = 0;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			var load_doc1 = load("res://resources/documents/Autopsia.tres")
			var load_doc2 = load("res://resources/documents/Ficha_Criminal.tres")
			var load_doc3 = load("res://resources/documents/Relatorio_Homicidio.tres")
			var load_doc4 = load("res://resources/documents/Jornal.tres")
			InventoryManager.add_document(load_doc1)
			InventoryManager.add_document(load_doc2)
			InventoryManager.add_document(load_doc3)
			InventoryManager.add_document(load_doc4)

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
		
