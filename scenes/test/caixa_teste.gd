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
	
	$".".visible = false
	
	GameManager.set_flag("caixa_inicial_aberta", true)
	
	GameManager.set_flag("has_black_stamp", true)
	GameManager.set_flag("has_ficha_criminal", true)
	GameManager.set_flag("has_fotos_animais", true)
	GameManager.set_flag("has_caixa_carimbo", true)
	
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Ficha_Criminal.tres"))
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/documents/Fotos_Animais.tres"))
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/stamps/BlackStamp.tres"))
	
	GameEvents.subtitle_requested.emit("Você", "'Você tem tudo o que precisa aqui'.", 1.5)
	await get_tree().create_timer(1.0).timeout
	GameEvents.subtitle_requested.emit("", "Você adquiriu 3 documentos.", 1)
	await get_tree().create_timer(1.0).timeout
	GameEvents.subtitle_requested.emit("Você", "Algumas fichas, documentos, papéis e-", 1.5)
	await get_tree().create_timer(1.0).timeout
	GameEvents.subtitle_requested.emit("Você", "Um carimbo preto.", 1.5)
	await get_tree().create_timer(1.0).timeout
	GameEvents.subtitle_requested.emit("", "Você adquiriu o carimbo preto.", 1)
	await get_tree().create_timer(3.0).timeout
	
	var tween2 = create_tween()
	tween2.tween_property(overlay, "color:a", 0.0, 1.5)
	await tween2.finished
	
	overlay.visible = false
	
	$"../PCScene".set_visible(true)
	await get_tree().create_timer(1.0).timeout
	GameEvents.change_player_state(GameEvents.player_states.walking)
	queue_free()
