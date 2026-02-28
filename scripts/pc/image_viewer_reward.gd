extends WindowBase
class_name ImageViewerReward

@onready var symbol_btn: Button = $Content/SymbolBtn

func _ready():
	super._ready()
	symbol_btn.pressed.connect(_on_symbol_clicked)

func _on_symbol_clicked():
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if pc:
		pc.install_toque_dourado_delayed(0.0)
		GameManager.set_flag("puzzle2_done", true)
		GameEvents.emit_signal("add_item_to_inventory", load("res://resources/stamps/YellowStamp.tres"))
		GameEvents.subtitle_requested.emit("", "Novo carimbo adicionado a mesa", 2.5)
		await get_tree().create_timer(1.0).timeout
	
	queue_free()
