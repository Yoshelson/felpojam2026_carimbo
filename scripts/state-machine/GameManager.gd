extends Node

# Carimbos
var has_black_stamp: bool = false
var has_blue_stamp: bool = false
var has_yellow_stamp: bool = false
var has_green_stamp: bool = false
var has_white_stamp: bool = false

# Itens
var has_ficha_criminal: bool = false
var has_fotos_animais: bool = false
var has_caixa_carimbo: bool = false
var has_autopsia: bool = false
var has_jornal: bool = false
var has_relatorio: bool = false

# Progresso dos puzzles
var puzzle1_done: bool = false  # senha computador
var puzzle2_done: bool = false  # morse
var puzzle3_done: bool = false  # messager
var puzzle4_done: bool = false  # palavras
var puzzle5_done: bool = false  # simbolos

# Estado do mundo
var caixa_inicial_aberta: bool = false
var maleta_aberta: bool = false
var guarda_roupa_aberto: bool = false

# Configurações do jogador (persistem entre cenas)
# sensitivity: multiplicador de rotação da câmera (base: 0.002)
var sensitivity: float = 0.002
# brightness: 0.0 = tela preta, 1.0 = padrão, 2.0 = muito claro
var brightness: float = 1.0
# subtitle_speed: intervalo entre caracteres do efeito typewrite (segundos)
var subtitle_speed: float = 0.03
# psx_enabled: estado do filtro PSX
var psx_enabled: bool = false


signal state_changed

func set_flag(flag: String, value: bool) -> void:
	set(flag, value)
	emit_signal("state_changed")
