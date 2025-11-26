extends CanvasLayer

@onready var fade = $ColorRect

func fade_out():
	fade.visible = true
	fade.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1, 1)

func fade_in():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0, 1)
	await tween.finished
	fade.visible = false
