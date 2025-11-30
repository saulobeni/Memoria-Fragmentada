extends MarginContainer

var texts_to_display := [
	"O Alzheimer é uma condição neurológica progressiva que afeta a memória, a identidade e a relação da pessoa com o mundo ao seu redor.\n
	Coisas simples, como lembrar um nome, reconhecer um rosto ou encontrar o caminho de casa, tornam-se desafios diários.\n
	Por trás de cada esquecimento existe alguém tentando manter sua história viva, lutando para compreender um mundo que parece mudar sem aviso.",

	"A cada nível, você acompanhará a rotina do protagonista, um idoso portador da doença que tenta manter sua independência apesar das dificuldades.\n
	Tarefas simples podem se tornar desafios inesperados.\n
	Conforme o jogo avança, a doença também progride, tornando algumas ações mais complexas.\n 
	Sua função será ajudá-lo a completar cada atividade dentro dessas novas condições.",

	"Agora, cabe a você decidir: está preparado para acompanhar este senhor em suas atividades diárias, lidando com as dificuldades que o Alzheimer traz?\n
	Ao longo da jornada, sua atenção e suas escolhas serão importantes para que ele consiga realizar cada tarefa.\n
	Siga em frente e veja como você pode ajudá-lo a enfrentar os desafios que surgirem."
]

var next_scene_path := "res://scenes/Dia_1.tscn"

var current_index : int = 0
var typing_speed : float = 0.05
var is_typing : bool = false
var skip_typing : bool = false

@onready var text_label: Label = $TextContainer/TextLabel
@onready var typing_sound: AudioStreamPlayer = $TypingSound   # ✅ SOM

func _ready() -> void:
	scale = Vector2.ZERO

	await get_tree().create_timer(1.0).timeout
	pivot_offset = size/2

	var open_tween = get_tree().create_tween()
	open_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

	if texts_to_display.size() > 0:
		show_text()


func show_text() -> void:
	is_typing = true
	skip_typing = false
	text_label.text = ""

	await get_tree().create_timer(0.3).timeout
	_type_text(texts_to_display[current_index])


func _type_text(text: String) -> void:
	if typing_sound and typing_sound.stream:
		typing_sound.stream.loop = true  # ✅ LOOP ATIVADO
		typing_sound.play()

	for i in range(text.length()):
		if skip_typing:
			text_label.text = text
			break

		text_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout

	typing_sound.stop()   # ✅ PARA O SOM
	is_typing = false


func _close_dialog() -> void:
	typing_sound.stop()

	var close_tween = get_tree().create_tween()
	close_tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
	await close_tween.finished

	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)

	queue_free()


func _unhandled_input(event) -> void:
	if not event.is_action_pressed("ui_accept"):
		return

	if is_typing:
		skip_typing = true
		typing_sound.stop()   # ✅ PARA AO PULAR
		return

	if current_index + 1 < texts_to_display.size():
		current_index += 1
		show_text()
	else:
		_close_dialog()
