extends WindowBase
class_name ImageViewerReward

@onready var symbol_btn: Button = $Content/SymbolBtn

func _ready():
	super._ready()
	symbol_btn.pressed.connect(_on_symbol_clicked)
	
	# Se o puzzle ja foi feito (jogador revendo a imagem),
	# desabilita o botao e remove o shader de brilho imediatamente
	if GameManager.puzzle2_done:
		_disable_symbol()

func _disable_symbol() -> void:
	symbol_btn.disabled = true
	symbol_btn.material = null  # remove o glow_outline shader

func _on_symbol_clicked():
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if pc:
		pc.install_toque_dourado_delayed(0.0)
		GameManager.set_flag("puzzle2_done", true)
		GameEvents.emit_signal("add_item_to_inventory", load("res://resources/stamps/YellowStamp.tres"))
		GameEvents.dialogue_requested.emit([
		{speaker = "", text = "A tinta Amarela foi desbloqueada."},
		{speaker = "[color=yellow]Desconhecido[/color]", text = "Você quer provar algo... não quer?"},
		{speaker = "Você:", text = "Quem falou isso? Tem alguem aí?"},
		])
		await GameEvents.dialogue_finished
		await get_tree().create_timer(0.5).timeout
	
	# Desabilita logo apos usar — nao pode clicar de novo ao reabrir
	_disable_symbol()
	queue_free()
