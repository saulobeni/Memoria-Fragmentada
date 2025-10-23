extends CharacterBody2D

@export var speed: float = 100.0

var direction: Vector2 = Vector2.ZERO
var last_direction: String = "front"  # "front", "back", "left", "right"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# --- Ler input (permite diagonais) ---
	direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	# --- Atualiza last_direction se houver input (para animação) ---
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "front" if direction.y > 0 else "back"
		
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO

	# --- Movimento e colisão ---
	move_and_slide()

	# --- Animação ---
	_update_animation(direction, last_direction)


func _update_animation(dir: Vector2, last_dir: String) -> void:
	if not anim:
		return

	var is_moving := dir != Vector2.ZERO

	match last_dir:
		"front":
			anim.animation = "front_walk" if is_moving else "front_stop"
		"back":
			anim.animation = "back_walk" if is_moving else "back_stop"
		"left":
			anim.animation = "walk_left" if is_moving else "walk_left_stop"
		"right":
			anim.animation = "walk_right" if is_moving else "walk_right_stop"

	anim.play()
