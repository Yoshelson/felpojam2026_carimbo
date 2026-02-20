@tool
extends Resource
class_name DocColorCombination

#Essa funcao abaixo permite que as cores fiquem em ordem alfabetica, mesmo quando
#colocadas no inspector do godot durante a criacao do resource. Um pouco bugado,
#mas garante que o codigo funcione da maneira correta. Futuramente pode ser 
#aprimorado
@export var colors_needed: Array[String]:
	set(value):
		colors_needed = value
		colors_needed.sort()
		#Esse e o sinal interno do godot que faz a magia acontecer
		emit_changed()
@export var variant_sprite: Texture2D
