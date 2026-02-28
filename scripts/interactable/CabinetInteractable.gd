extends Interactable

@export var document_rewards: Array[DocumentData]
@export var stamp_rewards: Array[StampData]

func interact(_interactor: Node3D):
	if (is_interactable):
		
		is_interactable = false
		_mesh.material_overlay = null
		
		if (GameManager.maleta_aberta):
			GameEvents.subtitle_requested.emit("Você", "Não preciso trocar de roupa.", 1)
			await get_tree().create_timer(1.0).timeout
		elif (true):
			_call_subtitles()
			_give_rewards()
			GameManager.maleta_aberta = true
		else:
			GameEvents.subtitle_requested.emit("Você", "Não preciso trocar de roupa e muito menos daquela maleta.", 2)
			await get_tree().create_timer(2.0).timeout
		
		is_interactable = true

func _give_rewards():
	for document in document_rewards:
		GameEvents.add_item_to_inventory.emit(document)
	for stamp in stamp_rewards:
		GameEvents.add_item_to_inventory.emit(stamp)

func _call_subtitles():
	GameEvents.subtitle_requested.emit("Você", "Certo, vamos colocar a senha...", 1.0)
	await get_tree().create_timer(1.0).timeout
	GameEvents.subtitle_requested.emit("Maleta", "[click]", 0.5)
	await get_tree().create_timer(0.5).timeout
	GameEvents.subtitle_requested.emit("Você", "Tem três papéis em branco e...", 1.5)
	await get_tree().create_timer(1.5).timeout
	GameEvents.subtitle_requested.emit("Você", "um carimbo azul.", 1.5)
	await get_tree().create_timer(1.5).timeout
	GameEvents.subtitle_requested.emit("", "Documentos adicionados ao Quadro de Documentos", 1)
	await get_tree().create_timer(1.0).timeout
	GameEvents.subtitle_requested.emit("", "Carimbo adicionado à mesa", 1)
	await get_tree().create_timer(3.0).timeout
