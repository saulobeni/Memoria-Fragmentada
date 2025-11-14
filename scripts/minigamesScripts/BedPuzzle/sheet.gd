extends Polygon2D

## ctrl + / ~~> Comenta multiplas linhas!!

const VERTEX_COUNT := 15
const WIDTH := 300
const HEIGHT := 200

const HANDLE_RADIUS_DRAW := 2   # raio do círculo visível
const HANDLE_RADIUS_HIT  := 20  # raio da área de clique

# const TARGET_RADIUS := 20         # área onde o vértice deve ser arrastado
const HANDLE_COLOR := Color.RED
# const TARGET_COLOR := Color(0,1,0,0.3)

var dragged_index := -1
# var targets := []
var game_completed := false

func _ready():
	set_process_input(true)
	polygon = generate_rectangle_vertices(WIDTH, HEIGHT, VERTEX_COUNT)
	$Label.visible = false
	color = Color(0.9, 0.9, 1.0)
	# generate_targets()
	queue_redraw()

func generate_rectangle_vertices(w, h, count):
	var verts: PackedVector2Array = []

	# perímetro total
	var perimeter = 2.0 * (w + h)

	# distância entre pontos
	var step = perimeter / count

	# gera vértices caminhando pelas bordas
	for i in range(count):
		var d = step * i

		if d <= w:  # borda superior
			verts.append(Vector2(-w/2 + d, -h/2))
		elif d <= w + h:  # borda direita
			verts.append(Vector2(w/2, -h/2 + (d - w)))
		elif d <= w*2 + h:  # borda inferior
			verts.append(Vector2(w/2 - (d - (w + h)), h/2))
		else:  # borda esquerda
			verts.append(Vector2(-w/2, h/2 - (d - (w*2 + h))))

	return verts

#func generate_targets():
	#targets.clear()
	#var top_count = 0
	#for v in polygon:
		#if v.y == -HEIGHT/2:
			#top_count += 1
#
	#for i in range(polygon.size()):
		#if i < top_count:
			#targets.append(polygon[i] + Vector2(randf() * 40 - 60, 0))
		#else:
			#targets.append(Vector2(10000, 10000))  # target “invisível” fora da tela
#
## checa se um vértice está dentro do target
#func is_vertex_in_target(index):
	#return polygon[index].distance_to(targets[index]) <= TARGET_RADIUS

func point_inside(point: Vector2, rect: RectangleShape2D) -> bool:
	return point.x >= -rect.extents.x and point.x <= rect.extents.x \
	   and point.y >= -rect.extents.y and point.y <= rect.extents.y


# checa se todos os vértices estão corretos
func check_completion() -> bool:
	# verifica os vértices do lado direito (x > 0)
	var target_area = $Area2D
	var shape = target_area.get_node("CollisionShape2D").shape as RectangleShape2D

	for i in range(polygon.size()):
		if polygon[i].x > 0:  # lado direito
			var global_pos = self.to_global(polygon[i])
			var local_pos = target_area.to_local(polygon[i])
			if not point_inside(local_pos, shape):
				return false
	return true
	
func _input(event):
	var mouse = get_local_mouse_position()
	# pegar vértice
	if event is InputEventMouseButton and event.pressed:
		for i in range(polygon.size()):
			if polygon[i].distance_to(mouse) < HANDLE_RADIUS_HIT:
				dragged_index = i
				break

	# soltar vértice
	if event is InputEventMouseButton and not event.pressed:
		dragged_index = -1
		if check_completion() and not game_completed:
			game_completed = true
			print("MiniGame completo!!")

	# arrastar
	if event is InputEventMouseMotion and dragged_index != -1:
		var verts = polygon
		verts[dragged_index] = mouse
		polygon = verts
		queue_redraw()

func _draw():
	# desenha o lençol
	draw_polygon(polygon, [color])

	# desenha os vértices
	for p in polygon:
		if p.x > 0:
			draw_circle(p, HANDLE_RADIUS_DRAW, HANDLE_COLOR)
	
	#for t in targets:
		#draw_circle(t, TARGET_RADIUS, TARGET_COLOR)
	
	if not game_completed and check_completion():
		game_completed = true
		print("MiniGame completo!!")
		$Label.visible = true
		$Label.text = "🛏️ MiniGame completo!!"
		$Label.modulate = Color(0, 1, 0)
