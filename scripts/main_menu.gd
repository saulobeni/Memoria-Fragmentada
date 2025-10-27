extends Control

# Acessa pelos nomes dos nós (independe do caminho completo)
@onready var btn_new   : Button = $Center/Menu/BtnNewGame
@onready var btn_sound : Button = $Center/Menu/BtnSound
@onready var btn_exit  : Button = $Center/Menu/BtnExit
@onready var music     : AudioStreamPlayer = $Music   # se não tiver Music, remova esta linha e o uso dela

var sound_on := true

func _ready() -> void:
	# foco inicial para teclado/controle
	btn_new.grab_focus()
	_update_sound_label()

	# conecta os sinais dos botões
	btn_new.pressed.connect(_on_new_game_pressed)
	btn_sound.pressed.connect(_on_sound_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)

func _on_new_game_pressed() -> void:
	# Trocar para a cena principal do jogo (a sua "casa")
	# Dica: no FileSystem, clique direito em house.tscn → "Copiar Caminho" e cole abaixo se for diferente.
	get_tree().change_scene_to_file("res://scenes/main.tscn")

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
	btn_sound.text = "SOUND: ON" if sound_on else "SOUND: OFF"

func _on_exit_pressed() -> void:
	get_tree().quit()
