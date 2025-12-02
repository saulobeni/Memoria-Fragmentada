extends Area2D
@onready var trail := get_node("../Line2D")  # ajuste o caminho conforme sua hierarquia
var max_points := 18
var min_distance := 6

func _ready():
	setup_trail_gradient()

func _process(delta):
	global_position = get_global_mouse_position()
	update_trail()

func update_trail():
	if trail.points.is_empty() or trail.points[-1].distance_to(global_position) > min_distance:
		trail.add_point(global_position)
	
	if trail.points.size() > max_points:
		trail.remove_point(0)

func setup_trail_gradient():
	var gradient = Gradient.new()
	# Início do rastro (antigo) - transparente
	gradient.add_point(0.0, Color(1, 0, 0, 0))
	# Fim do rastro (recente) - opaco
	gradient.add_point(1.0, Color(1, 0, 0, 1))
	
	trail.gradient = gradient


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
