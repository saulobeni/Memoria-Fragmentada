extends Node2D

@onready var spawner = $FruitSpawner
@onready var container = $FruitContainer
@export var fruit_scene: PackedScene
@export var total_fruits := 20
@onready var message_label = $MessageLabel

var spawned := 0
var fruits_cut := 0

func _ready():
	message_label.visible = false
	spawn_next()

func spawn_next():
	if spawned >= total_fruits:
		return

	spawned += 1

	var fruit = fruit_scene.instantiate()
	fruit.position = Vector2(randf_range(150, 650), 100)

	fruit.connect("tree_exited", Callable(self, "_on_fruit_removed"))
	container.add_child(fruit)

	await get_tree().create_timer(randf_range(1.2, 2.0)).timeout
	spawn_next()

func _on_fruit_removed():
	fruits_cut += 1

	if fruits_cut >= total_fruits:
		end_minigame()

func end_minigame():
	show_message("🎉 MISSÃO CONCLUÍDA! 🎉")
	await get_tree().create_timer(3.0).timeout
	# Trocar de cena depois da mensagem
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

func show_message(text):
	message_label.text = text
	message_label.visible = true
	message_label.modulate.a = 0.0
	message_label.scale = Vector2(0.6, 0.6)

	# Animação suave
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(message_label, "scale", Vector2(1,1), 0.6).set_trans(Tween.TRANS_BACK)
