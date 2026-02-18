extends StaticBody3D

var opened := false

#O player tem o seecast que ao collidir com um objeto interativo E apertar um botão de interact (E, Enter ou Mouse esquerdo)
#o script do player irá verificar se tem a func interact
#Então, se for um objeto interativo, crie um script com a "func interact(_player: Player):" e em seguida coloque a interação
#PS: Lembrando de por a layer 3 no formato de colisão que é a colisão de objetos interativos.
#    pois é a única layer que o SeeCast vai ver.

func interact(_player: Player):
	print("interagiu")
	if opened:
		close_drawer()
	else:
		open_drawer()
	

#Fiz umas animações pra ver visualmente funcionar e é bem simples
func close_drawer():
		opened = false
		$AnimationPlayer.play("close")
	
func open_drawer():
		opened = true
		$AnimationPlayer.play("open")
	
