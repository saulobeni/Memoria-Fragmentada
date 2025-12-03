extends CharacterBody2D

@export var speed: float = 100
var direction: Vector2 = Vector2.ZERO
var last_direction: String = "front"  # "front", "back", "left", "right"
var can_move: bool = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var footstep_sound: AudioStreamPlayer2D = $FootstepSound

# Controle do intervalo entre passos
var footstep_timer := 0.0
const FOOTSTEP_INTERVAL = 0.4  # Intervalo em segundos entre cada passo
var was_moving := false  # Controla se estava andando no frame anterior

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO, last_direction)
		_handle_footsteps(delta, Vector2.ZERO)
		return
		
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
	
	# --- Som de passos ---
	_handle_footsteps(delta, direction)

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

func _handle_footsteps(delta: float, dir: Vector2) -> void:
	if not is_instance_valid(footstep_sound):
		return
	
	var is_moving := dir != Vector2.ZERO
	
	# Personagem está se movendo
	if is_moving:
		# Detecta quando começa a andar (transição de parado para andando)
		if not was_moving:
			# Toca o som imediatamente no primeiro passo
			footstep_sound.play()
			footstep_timer = 0.0
		else:
			# Continua o ciclo normal de passos
			footstep_timer += delta
			
			# Só toca se não estiver tocando E o intervalo passou
			if footstep_timer >= FOOTSTEP_INTERVAL and not footstep_sound.playing:
				footstep_sound.play()
				footstep_timer = 0.0
	else:
		# Personagem parou de se mover
		footstep_timer = 0.0
		
		# Para o som imediatamente se estiver tocando
		if footstep_sound.playing:
			footstep_sound.stop()
	
	# Atualiza o estado para o próximo frame
	was_moving = is_moving


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func enable_movement():
	can_move = true

func disable_movement():
	can_move = false
	velocity = Vector2.ZERO
	_update_animation(Vector2.ZERO, last_direction)
