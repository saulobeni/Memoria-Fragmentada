extends Area2D

@export var textures: Array[Texture2D] = []   # lista de sprites
var velocity: Vector2
var rotation_speed := 0.0
var cut_sound

func _ready():
	# pega o som do MiniGame (pai do container)
	cut_sound = get_tree().current_scene.get_node("CutSound")

	if not textures.is_empty():
		$Sprite2D.texture = textures.pick_random()

	velocity = Vector2(
		randf_range(-150, 150),
		randf_range(-420, -320)
	)

	rotation_speed = randf_range(-4.0, 4.0)


func _process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation += rotation_speed * delta

	if position.y > 900:
		queue_free()


func _on_area_entered(area):
	if area.name == "Knife":
		if cut_sound:
			cut_sound.play()
		queue_free()
