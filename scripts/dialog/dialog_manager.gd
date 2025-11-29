extends Node

@export var dialog_scene : PackedScene
var dialog_box = null
var is_showing_dialog : bool = false

signal dialog_completed()

func start_dialog(texts: Array[String], dialog_position: Vector2, images: Array[AtlasTexture]):
	if is_showing_dialog:
		return
	if dialog_scene:
		dialog_box = dialog_scene.instantiate()
		get_tree().current_scene.add_child(dialog_box)
		
		dialog_box.z_index = 5
		
		dialog_box.texts_to_display = texts
		dialog_box.images_to_display = images
		dialog_box.global_position = dialog_position
		dialog_box.show_text()
		is_showing_dialog = true
		
		dialog_box.dialog_finished.connect(_on_dialog_finished)
		
func _on_dialog_finished():
	is_showing_dialog = false
	dialog_completed.emit()
	if dialog_box:
		dialog_box.queue_free()
		dialog_box = null
