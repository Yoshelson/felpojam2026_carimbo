extends CanvasLayer

@onready var text_label = $Control/PanelContainer/MarginContainer/RichTextLabel

func _ready() -> void:
	self.hide()
	GameEvents.subtitle_requested.connect(change_text)

func change_text(name: String, new_text: String, duration: float):
	text_label.text = new_text

#Lembrar que a legenda é similar a uma legenda de filme, uma letra branco com um 
#contorno preto ao redor e um fundo levemente preto para destaque. A esquerda o
#nome do personagem em com ":" após (usar o richtextlabel pra deixar mais 
#destacado

#Fazer o tamanho do panel se adaptar ao tamanho do change_text
