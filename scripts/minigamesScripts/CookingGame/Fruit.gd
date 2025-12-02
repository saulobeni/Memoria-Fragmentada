extends Area2D
@export var textures: Array[Texture2D] = []
var velocity: Vector2
var rotation_speed := 0.0
var cut_sound
var is_cut := false
var slice_scene  # precarregar a cena aqui
signal fruit_cut

func _ready():
	cut_sound = get_tree().current_scene.get_node("CutSound")
	# PRELOAD MOVIDO PARA CÁ - evita lag no corte
	slice_scene = preload("res://scenes/minigamesScenes/CookingGame/fruit_slice.tscn")
	
	# escolher textura aleatória
	if not textures.is_empty():
		$Sprite2D.texture = textures.pick_random()
	
	# física inicial
	velocity = Vector2(
		randf_range(-150, 150),
		randf_range(-420, -320)
	)
	rotation_speed = randf_range(-4.0, 4.0)

func _process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation += rotation_speed * delta
	
	# remover se cair fora da tela
	if position.y > 900:
		queue_free()

func _on_area_entered(area):
	if area.name == "Knife" and not is_cut:
		is_cut = true
		
		if cut_sound:
			cut_sound.play()
		
		create_slices()
		
		# Emite sinal de fruta cortada ANTES de remover
		emit_signal("fruit_cut")
		
		queue_free()

func create_slices():
	for i in range(2):
		var slice = slice_scene.instantiate()
		slice.position = position
		slice.rotation = rotation
		
		# aplicar corte
		slice.setup(
			$Sprite2D.texture,
			i == 0  # true = esquerda, false = direita
		)
		
		# física dos pedaços
		var side_direction = (1 if i == 0 else -1)
		slice.velocity = Vector2(
			velocity.x + randf_range(100, 200) * side_direction,
			velocity.y - randf_range(50, 150)
		)
		slice.rotation_speed = randf_range(-6.0, 6.0)
		
		get_parent().add_child(slice)
