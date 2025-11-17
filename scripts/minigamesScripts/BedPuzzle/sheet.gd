extends Polygon2D

const HANDLE_RADIUS_DRAW: float = 5
const HANDLE_RADIUS_HIT: float = 10

const HANDLE_COLOR: Color = Color.RED
const LINE_COLOR: Color = Color(0.151, 0.62, 1.0, 1.0)

var dragged_index: int = -1
var top_indices: Array[int] = []
var game_completed: bool = false

func _ready() -> void:
	set_process_input(true)

	# cor do lençol
	color = Color(0.151, 0.62, 1.0, 1.0)

	# gera o lençol (retângulo com muitos vértices)
	#polygon = generate_cloth_vertices(280, 180.0, 5)

	# encontra os vértices do topo
	top_indices = get_top_vertices()

	$Label.visible = false
	queue_redraw()


# ============================================================
# GERAR LENÇOL
# ============================================================

func generate_cloth_vertices(w: float, h: float, count: int) -> PackedVector2Array:
	var verts: PackedVector2Array = PackedVector2Array()
	var half_w: float = w * 0.5
	var half_h: float = h * 0.5

	# gerar topo (count vértices)
	for i in range(count):
		var t: float = float(i) / float(count - 1)
		var x: float = lerp(-half_w, half_w, t)
		verts.append(Vector2(x, -half_h))  # topo

	# gerar base (count vértices)
	for i in range(count):
		var t2: float = float(i) / float(count - 1)
		var x2: float = lerp(half_w, -half_w, t2)
		verts.append(Vector2(x2, half_h))  # baixo

	return verts


# ============================================================
# ACHAR OS VÉRTICES DO TOPO
# ============================================================

func get_top_vertices() -> Array[int]:
	var top: Array[int] = []
	var min_y: float = INF

	for v in polygon:
		if v.y < min_y:
			min_y = v.y

	for i in range(polygon.size()):
		if abs(polygon[i].y - min_y) < 2.0:
			top.append(i)

	return top


# ============================================================
# CHECAR COMPLEÇÃO (vértices do topo dentro da faixa verde)
# ============================================================

func check_completion() -> bool:
	var finish_area: Area2D = $AreaFinish
	var space := get_world_2d().direct_space_state

	for i in top_indices:
		var global_pos: Vector2 = self.to_global(polygon[i])

		var query := PhysicsPointQueryParameters2D.new()
		query.position = global_pos
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.exclude = []

		var result = space.intersect_point(query)

		var inside := false
		for hit in result:
			if hit.collider == finish_area:
				inside = true
				break

		if not inside:
			return false

	return true


func point_inside(p: Vector2, rect: RectangleShape2D) -> bool:
	return (
		p.x >= -rect.extents.x and p.x <= rect.extents.x
		and p.y >= -rect.extents.y and p.y <= rect.extents.y
	)


# ============================================================
# INPUT / ARRASTAR DOS VÉRTICES
# ============================================================

func _input(event: InputEvent) -> void:
	var mouse: Vector2 = get_local_mouse_position()

	# pegar vértice
	if event is InputEventMouseButton and event.pressed:
		for i in top_indices:
			if polygon[i].distance_to(mouse) < HANDLE_RADIUS_HIT:
				dragged_index = i
				break

	# soltar vértice
	if event is InputEventMouseButton and not event.pressed:
		dragged_index = -1

		# completar jogo
		if not game_completed and check_completion():
			game_completed = true
			show_completion()

	# arrastar
	if event is InputEventMouseMotion and dragged_index != -1:
		var verts: PackedVector2Array = polygon
		verts[dragged_index] = mouse
		polygon = verts
		queue_redraw()


# ============================================================
# VISUAL
# ============================================================

func _draw() -> void:
	# desenha lençol
	draw_polygon(polygon, [color])

	# contorno
	draw_polyline(polygon, LINE_COLOR, 1.5)

	# vértices arrastáveis (somente topo)
	for i in top_indices:
		draw_circle(polygon[i], HANDLE_RADIUS_DRAW, HANDLE_COLOR)


# ============================================================
# COMPLEÇÃO
# ============================================================

func show_completion() -> void:
	$Label.visible = true
	$Label.text = "🛏 Lençol arrumado!"
	$Label.modulate = Color(0.999, 0.988, 0.994, 1.0)
	print("🏁 Minigame completo!")
	
	await get_tree().create_timer(3.0).timeout
	# Trocar de cena depois da mensagem
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")
