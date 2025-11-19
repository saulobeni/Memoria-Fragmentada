extends Control

# Acessa pelos nomes dos nós (independe do caminho completo)
@onready var btn_new   : Button = $Center/Menu/BtnNewGame
@onready var btn_sound : Button = $Center/Menu/BtnSound
@onready var btn_exit  : Button = $Center/Menu/BtnExit
@onready var music     : AudioStreamPlayer = $Music   # se não tiver Music, remova esta linha e o uso dela

# Som de clique dos botões
@onready var btn_click_sound : AudioStreamPlayer = $BtnClickSound

@onready var animation_transition : AnimationPlayer = $Transicao/ColorRect/AnimationPlayer

var sound_on := true


func _ready() -> void:
	# foco inicial para teclado/controle
	# conecta os sinais dos botões
	btn_new.pressed.connect(_on_new_game_pressed)
	btn_sound.pressed.connect(_on_sound_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	# conecta sons de CLICK em todos os botões
	btn_new.pressed.connect(_play_click_sound)
	btn_sound.pressed.connect(_play_click_sound)
	btn_exit.pressed.connect(_play_click_sound)

func _setup_button_styles() -> void:
	# Cores para diferenciar estado normal e focado
	var focus_color = Color.YELLOW  # Cor quando botão está focado
	var normal_color = Color.WHITE  # Cor normal
	
	# Aplica a configuração para cada botão
	_configure_button_style(btn_new, normal_color, focus_color)
	_configure_button_style(btn_sound, normal_color, focus_color)
	_configure_button_style(btn_exit, normal_color, focus_color)

func _configure_button_style(button: Button, normal_color: Color, focus_color: Color) -> void:
	# Configura as cores do texto para cada estado
	btn_new.grab_focus()
	btn_new.grab_focus()
	button.add_theme_color_override("font_focus_color", focus_color)
	button.add_theme_color_override("font_hover_color", focus_color)
	button.add_theme_color_override("font_pressed_color", focus_color)
	_update_sound_label()
	
func _play_click_sound() -> void:
	if sound_on and is_instance_valid(btn_click_sound):
		btn_click_sound.play()

func _on_new_game_pressed() -> void:
	animation_transition.play("transicao_vai")
	await animation_transition.animation_finished
	
	# Trocar para a cena principal do jogo (a sua "casa")
	get_tree().change_scene_to_file("res://scenes/introduction_game.tscn")

func _on_sound_pressed() -> void:
	sound_on = not sound_on
	if is_instance_valid(music):
		if sound_on:
			if not music.playing:
				music.play()
		else:
			music.stop()
	_update_sound_label()

func _update_sound_label() -> void:
	btn_sound.text = "SOM: LIGADO" if sound_on else "SOM: DESLIGADO"

func _on_exit_pressed() -> void:
	get_tree().quit()
