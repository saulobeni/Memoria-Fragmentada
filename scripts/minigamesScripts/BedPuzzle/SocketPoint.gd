# SocketPoint.gd
extends Area2D

@export var socket_radius: float = 5.0
@export var pull_strength: float = 5.0
@export var auto_complete: bool = true

var is_occupied: bool = false
var target_vertex_index: int = -1

func _ready() -> void:
	# Cria colisão circular
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = socket_radius
	collision.shape = shape
	add_child(collision)
	
	# Sinal para debug
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _draw() -> void:
	# Desenha o socket (círculo transparente com borda)
	if is_occupied:
		# Correção: usar Color() com alpha diretamente
		draw_circle(Vector2.ZERO, socket_radius, Color(0, 1, 0, 0.3))  # Verde com alpha
	else:
		draw_circle(Vector2.ZERO, socket_radius, Color(1, 1, 0, 0.3))  # Amarelo com alpha
	
	draw_arc(Vector2.ZERO, socket_radius, 0, TAU, 32, Color.WHITE, 2.0)
	
	# Desenha um ponto central
	draw_circle(Vector2.ZERO, 1, Color.WHITE)

func _on_body_entered(_body: Node) -> void:
	queue_redraw()

func _on_body_exited(_body: Node) -> void:
	queue_redraw()
