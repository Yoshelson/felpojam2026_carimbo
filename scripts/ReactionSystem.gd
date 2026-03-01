extends Node

var reaction_event1 = {
	"doc_id":["ficha_criminal"], 
	"stamp_list": ["Preto"], 
	"func": surpresa_tinta,
	"was_executed": false}

var reaction_event2 = {
	"doc_id":["autopsia", "relatorio_homicidio"], 
	"stamp_list": ["Preto"], 
	"func": vinganca_mae,
	"was_executed": false}
	
var reaction_event3 = {
	"doc_id":["jornal"], 
	"stamp_list": ["Preto"], 
	"func": jornal,
	"was_executed": false}

var reaction_event4 = {
	"doc_id":["autopsia", "relatorio_homicidio"], 
	"stamp_list": ["Preto", "Azul", "Amarelo"], 
	"func": carimbo_verde,
	"was_executed": false}
	
var array = [reaction_event1,reaction_event2,reaction_event3,reaction_event4]

func _ready() -> void:
	InventoryManager.stamp_applied.connect(_check_reaction)

func _check_reaction(doc_id: String, applied_stamps: Array[String]):
	for event in array:
		if not event["was_executed"]:
			if event["doc_id"].has(doc_id):
				if(_has_required_colors(event["stamp_list"], applied_stamps)):
					event["was_executed"] = true
					event["func"].call()
		
		
func _has_required_colors (colors_needed, applied_colors) -> bool:
	for color in colors_needed:
		if !(applied_colors.has(color)):
			return false
	return true

#GameEvents.dialogue_requested.emit([
	#{speaker = "Você:", text = "Certo, \"carimbo\", e o que uma pessoa como eu poderia desejar?"},
	#{speaker = "Carimbo", text = "Você sabe o que quer com seu pai. Foi assim com a Monique também."},
	#{speaker = "Você", text = "Ele não é meu pai, nunca foi. "},
	#{speaker = "Você", text = "Eu vou trazer a ruína para tudo que ele construiu."},
	#{speaker = "Você", text = "E eu o ceifarei com minhas próprias mãos."},
	#{speaker = "Carimbo", text = "E nós tornaremos isso ser realidade."},
	#])
	#await GameEvents.dialogue_finished




func surpresa_tinta():
	GameEvents.dialogue_requested.emit([
	{speaker = "Você:", text = "Oque?? a tinta-"},
	{speaker = "Você:", text = "A tinta do carimbo formou uma imagem?"},
	{speaker = "Você", text = "..."},
	{speaker = "Você", text = "Eu acho que isso é uma tecnologia que ele comprou para acobertar o crime."},
	{speaker = "Você", text = "Que fútil Midas, você não vai me parar"},
	])
	await GameEvents.dialogue_finished
	print ("Meu deus a Tinta")

func vinganca_mae():
	GameEvents.subtitle_requested.emit("Você", "Mãe, eu vou fazer ele se arrepender por cada segundo do que ele fez com você.", 2)
	print ("Vou te vingar mae")

func jornal():
	GameEvents.subtitle_requested.emit("Você", "Sempre o “melhor”. Quem é o superior agora, Midas? ", 2)
	GameEvents.subtitle_requested.emit("Você", "O assassino que foge de tudo e vai ver sua empresa vai ruir?", 2)
	print ("ODEIO vc pai - Jornal")

func carimbo_verde():
	GameEvents.dialogue_requested.emit([
	{speaker = "Você:", text = "As tintas se misturaram e formaram uma nova cor? um novo símbolo?"},
	{speaker = "Desconhecido", text = "Existe uma última tinta... que ele se esforçou muito para escondê-la."},
	{speaker = "Você", text = "Quem é você e como sabe tanto sobre isso tudo?"},
	{speaker = "Desconhecido", text = "Entre a sua espécie, eu sou conhecido como Carimbo."},
	{speaker = "Carimbo", text = "Eu entreguei a ele o que ele desejava."},
	{speaker = "Carimbo", text = "E agora… você também deseja"},
	{speaker = "Carimbo", text = "Termine a investigação e falaremos"},
	])
	await GameEvents.dialogue_finished
	GameManager.set_flag("has_green_stamp", true)
	GameEvents.emit_signal("add_item_to_inventory", load("res://resources/stamps/GreenStamp.tres"))
	print("Ganhou o carimbo verde")
