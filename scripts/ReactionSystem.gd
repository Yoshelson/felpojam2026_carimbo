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
	
func surpresa_tinta():
	print ("Meu deus a Tinta")
	
func vinganca_mae():
	print ("Vou te vingar mae")
	
func jornal():
	print ("ODEIO vc pai - Jornal")

func carimbo_verde():
	print("Ganhou o carimbo verde")
