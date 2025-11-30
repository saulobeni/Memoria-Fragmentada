extends Control

# Acessa pelos nomes dos nós (independe do caminho completo)
@onready var btn_new   : Button = $Center/Menu/BtnNewGame
@onready var btn_sound : Button = $Center/Menu/BtnSound
@onready var btn_exit  : Button = $Center/Menu/BtnExit

# Som de clique dos botões
@onready var btn_click_sound : AudioStreamPlayer = $BtnClickSound

@onready var animation_transition : AnimationPlayer = $Transicao/ColorRect/AnimationPlayer

var sound_on := true


func _ready() -> void:
	# conecta os sinais dos botões
	btn_new.pressed.connect(_on_new_game_pressed)
	btn_sound.pressed.connect(_on_sound_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	# sons de clique
	btn_new.pressed.connect(_play_click_sound)
	btn_sound.pressed.connect(_play_click_sound)
	btn_exit.pressed.connect(_play_click_sound)
	
	# TOCA A MÚSICA (global)
	MusicManager.play()


func _play_click_sound() -> void:
	if sound_on and is_instance_valid(btn_click_sound):
		btn_click_sound.play()


func _on_new_game_pressed() -> void:
	if btn_new.disabled:
		return

	btn_new.disabled = true

	animation_transition.play("transicao_vai")
	await animation_transition.animation_finished

	get_tree().change_scene_to_file("res://scenes/introduction_game.tscn")


func _on_sound_pressed() -> void:
	sound_on = not sound_on
	
	# Controla o som GLOBAL
	MusicManager.set_enabled(sound_on)
	
	_update_sound_label()


func _update_sound_label() -> void:
	btn_sound.text = "SOM: LIGADO" if sound_on else "SOM: DESLIGADO"


func _on_exit_pressed() -> void:
	get_tree().quit()
