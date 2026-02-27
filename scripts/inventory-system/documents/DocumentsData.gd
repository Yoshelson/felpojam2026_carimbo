extends Resource

class_name DocumentData

@export var base_image: Texture2D
@export var id: String
@export_multiline var base_transcripted_text: String
@export var variations: Array[DocColorCombination]
@export var requires_color_order: bool
@export var board_pos: Vector3
@export var prefab_scene: PackedScene
