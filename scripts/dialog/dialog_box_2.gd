extends MarginContainer

signal dialog_finished()

var texts_to_display: Array[String] = []
var images_to_display: Array[AtlasTexture] = []
var current_index : int = 0
var typing_speed : float = 0.05
var is_typing : bool = false

@onready var text_label : Label = $text_container/text_label
@onready var character_sprite : Sprite2D = $character
@onready var typing_sound : AudioStreamPlayer = $TypingSound
@onready var tween : Tween = get_tree().create_tween()

func _ready() -> void:
	pivot_offset = size / 2
	scale = Vector2.ZERO

	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

	if texts_to_display.size() > 0:
		show_text()

func show_text():
	print("show_text() foi chamado! index =", current_index)
	if current_index < texts_to_display.size():
		is_typing = true
		text_label.text = ""

		if current_index < images_to_display.size() and images_to_display[current_index]:
			character_sprite.texture = images_to_display[current_index]
			character_sprite.visible = true
		else:
			character_sprite.visible = false

		_type_text(texts_to_display[current_index])
	else:
		_close_dialog()

func _type_text(text: String):
	print("DIGITANDO TEXTO...")

	typing_sound.play()   # ✅ TOCA AQUI
	print("Som tocando:", typing_sound.playing)

	for i in range(text.length()):
		if not is_typing:
			break

		text_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout

	typing_sound.stop()   # ✅ PARA AQUI
	is_typing = false

func _close_dialog():
	typing_sound.stop()
	is_typing = false

	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
	await tween.finished

	dialog_finished.emit()
	queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			is_typing = false
			text_label.text = texts_to_display[current_index]
			typing_sound.stop()
		else:
			if current_index + 1 < texts_to_display.size():
				current_index += 1
				show_text()
			else:
				_close_dialog()
