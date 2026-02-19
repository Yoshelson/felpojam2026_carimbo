extends Control

signal login_success

@export var correct_password : String = "1995"

@onready var password : LineEdit = $Password
@onready var errorlabel : Label = $ErrorLabel
@onready var confirm : Button = $Confirm


var unlocked := false

func _ready():
	errorlabel.visible = false
	password.secret = true
	password.grab_focus()

func _on_confirm_pressed():
	if unlocked:
		return
	
	if password.text == correct_password:
		unlocked = true
		login_success.emit()
		queue_free()
	else:
		show_error()
	


func show_error():
	errorlabel.text = "Senha Incorreta"
	errorlabel.visible = true
	password.clear()
	password.grab_focus()
	
