extends SimpleInteractable

@onready var overlay: ColorRect = $"../Overlay"

func interact(_interactor: Node3D):
	if not is_interactable:
		return
	is_interactable = false
	_mesh.material_overlay = null
	prompt_message = ""
	play_sfx()

	GameEvents.change_player_state(GameEvents.player_states.cinematic_ui)

	overlay.visible = true
	overlay.color.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 1.5)
	await tween.finished
	overlay.color.a = 1.0
	$"../QUARTO HOTEL FINALIZADO/CAIXA".visible = false
	$"../QUARTO HOTEL FINALIZADO/TAMPA 1".visible = false
	$"../QUARTO HOTEL FINALIZADO/TAMPA 2col".visible = false
	$".".visible = false
	
	GameManager.set_flag("caixa_inicial_aberta", true)
	GameManager.set_flag("has_black_stamp", true)
	GameManager.set_flag("has_ficha_criminal", true)
	GameManager.set_flag("has_fotos_animais", true)
	GameManager.set_flag("has_caixa_carimbo", true)

	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Ficha_Criminal.tres"))
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Fotos.tres"))
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/stamps/BlackStamp.tres"))

	GameEvents.dialogue_requested.emit([
	{speaker = "Você:", text = "O computador da Monique, 2 folhas em branco-"},
	{speaker = "Você:", text = "Uma Maleta e uma caixa extravagante com um carimbo de tinta preta e um papel…"},
	{speaker = "Papel", text = "'Não use esse carimbo a todo custo'"},
	{speaker = "Você:", text = "Apenas mais uma das asnice dele."}
	])
	await GameEvents.dialogue_finished

	var tween2 = create_tween()
	tween2.tween_property(overlay, "color:a", 0.0, 1.5)
	await tween2.finished
	overlay.visible = false

	# Desbloqueia PC
	var pc = get_node_or_null("../PCScene")
	var pc_baixo = get_node_or_null("../QUARTO HOTEL FINALIZADO/teclado")
	var pc_cima = get_node_or_null("../QUARTO HOTEL FINALIZADO/tampa de cima")
	if pc:
		pc.visible = true
		pc_cima.visible = true
		pc_baixo.visible = true
		pc.set_deferred("monitoring", true)
		# Garante que o interactable está ativo
		if pc.has_method("set") and "is_interactable" in pc:
			pc.is_interactable = true

	# Desbloqueia Quadro de Documentos
	var board = get_node_or_null("../DocumentBoard")
	if board:
		board.set_deferred("monitoring", true)
		if board.has_method("set") and "is_interactable" in board:
			board.is_interactable = true

	await get_tree().create_timer(0.5).timeout
	GameEvents.change_player_state(GameEvents.player_states.walking)
	queue_free()
