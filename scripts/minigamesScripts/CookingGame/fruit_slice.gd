extends Area2D
var velocity: Vector2
var rotation_speed := 0.0
var fade_speed := 2.0
var is_cut := true

func _ready():
	# desaparece depois de 1s
	await get_tree().create_timer(1.0).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation += rotation_speed * delta

# VERSÃO OTIMIZADA - usa AtlasTexture ao invés de processar pixel por pixel
func setup(texture: Texture2D, is_left: bool):
	var sprite = $Sprite2D
	
	# Criar AtlasTexture que mostra apenas metade da imagem
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	
	var width = texture.get_width()
	var height = texture.get_height()
	
	# Define qual metade da textura será mostrada
	if is_left:
		atlas.region = Rect2(0, 0, width / 2, height)
		sprite.offset.x = -width / 4.0
	else:
		atlas.region = Rect2(width / 2, 0, width / 2, height)
		sprite.offset.x = width / 4.0
	
	sprite.texture = atlas
