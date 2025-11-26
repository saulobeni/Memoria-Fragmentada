extends CharacterBody2D

@export var speed := 120
var moving := false
var target_position: Vector2

func move_to(pos: Vector2) -> void:
	target_position = pos
	moving = true

func _physics_process(delta: float) -> void:
	if moving:
		var dir = (target_position - position).normalized()
		velocity = dir * speed
		move_and_slide()
		if position.distance_to(target_position) < 5:
			moving = false
			velocity = Vector2.ZERO
