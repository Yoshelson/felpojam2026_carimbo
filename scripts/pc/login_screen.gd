extends Control
signal login_success

@export var correct_password : String = "2009"
@export var recovery_questions := [
	{
		"question": "Data de Aniversário (xx/xx/xxxx)",
		"answer": "16/02/1984"
	},
	{
		"question": "Cidade Natal",
		"answer": "SAO PAULO",
		"answer_alt": "SÃO PAULO"
	},
	{
		"question": "O dia do meu maior arrependimento",
		"answer": "13"
	}
]

@onready var login_panel : Control = $LoginScreen
@onready var recoverybutton : Button = $LoginScreen/ForgotPassword
@onready var password : LineEdit = $LoginScreen/Password
@onready var errorlabel : Label = $LoginScreen/ErrorLabel
@onready var confirm : Button = $LoginScreen/Confirm
@onready var recovery_panel : Control = $RecoveryScreen
@onready var question_label : Label = $RecoveryScreen/QuestionLabel
@onready var answer_field : LineEdit = $RecoveryScreen/AnswerLine
@onready var confirm_recovery : Button = $RecoveryScreen/ConfirmRecovery
@onready var recovery_error : Label = $RecoveryScreen/ErrorLabel
@onready var back_button : Button = $RecoveryScreen/BackButton

var unlocked := false
var current_question := 0

func _ready():
	errorlabel.visible = false
	password.secret = true

	recovery_panel.visible = false
	recovery_error.visible = false

	if not confirm.pressed.is_connected(_on_confirm_pressed):
		confirm.pressed.connect(_on_confirm_pressed)
	recoverybutton.pressed.connect(_on_forgot_pressed)
	confirm_recovery.pressed.connect(_on_confirm_recovery_pressed)
	back_button.pressed.connect(_on_back_pressed)

	password.text_submitted.connect(func(_t): _on_confirm_pressed())
	answer_field.text_submitted.connect(func(_t): _on_confirm_recovery_pressed())

	password.text_changed.connect(func(t):
		password.text = t.to_upper()
		password.caret_column = password.text.length()
	)
	answer_field.text_changed.connect(func(t):
		answer_field.text = t.to_upper()
		answer_field.caret_column = answer_field.text.length()
	)

func _on_confirm_pressed():
	if unlocked:
		return
	if password.text == correct_password:
		unlocked = true
		login_success.emit()
		GameManager.set_flag("puzzle1_done", true)
		queue_free()
	else:
		show_error()

func show_error():
	errorlabel.text = "Senha Incorreta"
	errorlabel.visible = true
	password.clear()

func _on_forgot_pressed():
	login_panel.visible = false
	recovery_panel.visible = true
	current_question = 0
	_show_question()

func _show_question():
	recovery_error.visible = false
	answer_field.clear()
	if current_question < recovery_questions.size():
		question_label.text = recovery_questions[current_question]["question"]
	else:
		_show_password_reset()

func _show_password_reset():
	question_label.text = "Senha redefinida para: " + correct_password
	answer_field.visible = false
	confirm_recovery.visible = false
	recovery_error.visible = false

func _on_confirm_recovery_pressed():
	var player_answer = answer_field.text.strip_edges()
	var q = recovery_questions[current_question]
	var correct = q["answer"]
	var correct_alt = q.get("answer_alt", "")

	if player_answer != correct and player_answer != correct_alt:
		recovery_error.text = "Resposta errada, tente novamente."
		recovery_error.visible = true
		return
	current_question += 1
	_show_question()

func _on_back_pressed():
	recovery_panel.visible = false
	login_panel.visible = true
	answer_field.visible = true
	confirm_recovery.visible = true
	current_question = 0
