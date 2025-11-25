extends Polygon2D

const HANDLE_RADIUS_DRAW: float = 5
const HANDLE_RADIUS_HIT: float = 10
const HANDLE_COLOR: Color = Color.RED
const LINE_COLOR: Color = Color(0.151, 0.62, 1.0, 1.0)

var dragged_index: int = -1
var top_indices: Array[int] = []
var game_completed: bool = false

# Sistema de sockets
var socket_points: Array[Node] = []
var vertex_socket_assignments: Dictionary = {} # vertex_index -> socket
var socket_radius: float = 20.0
var pull_strength: float = 15.0

func _ready() -> void:
	set_process_input(true)

	# cor do lençol
	color = Color(0.151, 0.62, 1.0, 1.0)
	
	# encontra os vértices do topo
	top_indices = get_top_vertices()

	# Encontra todos os sockets na cena
	find_socket_points()
	
	$Label.visible = false
	queue_redraw()

func find_socket_points() -> void:
	socket_points.clear()
	# Procura por todos os SocketPoints na cena
	for child in get_children():
		if child is Area2D and child.has_method("_draw"): # Identificação simples
			socket_points.append(child)
	
	print("Encontrados ", socket_points.size(), " sockets")

# SISTEMA DE SOCKETS - ATUALIZAÇÃO NO _PROCESS
func _process(delta: float) -> void:
	if not game_completed:
		update_socket_attraction(delta)
		queue_redraw()

func update_socket_attraction(delta: float) -> void:
	var verts: PackedVector2Array = polygon
	
	for socket in socket_points:
		var closest_vertex_index = -1
		var closest_distance = socket_radius
		
		# Encontra o vértice mais próximo deste socket
		for i in top_indices:
			# Pula vértices que já estão sendo arrastados ou já atribuídos
			if i == dragged_index or vertex_socket_assignments.has(i):
				continue
				
			var distance = verts[i].distance_to(socket.position)
			if distance < closest_distance and distance < socket_radius:
				closest_distance = distance
				closest_vertex_index = i
		
		# Aplica atração se encontrou um vértice próximo
		if closest_vertex_index != -1:
			var direction = (socket.position - verts[closest_vertex_index]).normalized()
			var attraction_force = direction * pull_strength * delta
			
			# Move o vértice em direção ao socket
			verts[closest_vertex_index] += attraction_force
			
			# Se está muito próximo, "encaixa" no socket
			if verts[closest_vertex_index].distance_to(socket.position) < 5.0:
				verts[closest_vertex_index] = socket.position
				vertex_socket_assignments[closest_vertex_index] = socket
				socket.is_occupied = true
				socket.target_vertex_index = closest_vertex_index
				socket.queue_redraw()
	
	# Atualiza o polígono
	polygon = verts
	
	# Verifica completação
	if not game_completed and check_completion():
		game_completed = true
		show_completion()

# ACHAR OS VÉRTICES DO TOPO
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

# CHECAR COMPLEÇÃO
func check_completion() -> bool:
	# Verifica se todos os sockets estão ocupados
	for socket in socket_points:
		if not socket.is_occupied:
			return false
	
	# Se todos os sockets estão ocupados, o jogo está completo
	return true

# Função auxiliar para criar cores com alpha
func color_with_alpha(base_color: Color, alpha: float) -> Color:
	return Color(base_color.r, base_color.g, base_color.b, alpha)

# INPUT / ARRASTAR DOS VÉRTICES
func _input(event: InputEvent) -> void:
	var mouse: Vector2 = get_local_mouse_position()

	# Pegar vértice
	if event is InputEventMouseButton and event.pressed:
		for i in top_indices:
			if polygon[i].distance_to(mouse) < HANDLE_RADIUS_HIT:
				dragged_index = i
				# Libera o socket se estava ocupado
				if vertex_socket_assignments.has(i):
					var old_socket = vertex_socket_assignments[i]
					old_socket.is_occupied = false
					old_socket.target_vertex_index = -1
					old_socket.queue_redraw()
					vertex_socket_assignments.erase(i)
				break

	# Soltar vértice
	if event is InputEventMouseButton and not event.pressed:
		if dragged_index != -1:
			# Verifica se soltou próximo a algum socket
			check_socket_snap(dragged_index)
			dragged_index = -1

	# Arrastar
	if event is InputEventMouseMotion and dragged_index != -1:
		var verts: PackedVector2Array = polygon
		verts[dragged_index] = mouse
		polygon = verts
		queue_redraw()

func check_socket_snap(vertex_index: int) -> void:
	var verts: PackedVector2Array = polygon
	var vertex_pos = verts[vertex_index]
	
	for socket in socket_points:
		# Pula sockets já ocupados
		if socket.is_occupied:
			continue
			
		var distance = vertex_pos.distance_to(socket.position)
		if distance < socket_radius:
			# Encaixa no socket
			verts[vertex_index] = socket.position
			polygon = verts
			
			# Registra a atribuição
			vertex_socket_assignments[vertex_index] = socket
			socket.is_occupied = true
			socket.target_vertex_index = vertex_index
			socket.queue_redraw()
			
			print("Vértice ", vertex_index, " encaixado no socket")
			break

# VISUAL
func _draw() -> void:
	# Desenha lençol
	draw_polygon(polygon, [color])
	
	# Contorno
	var outline_color = Color.GREEN if game_completed else LINE_COLOR
	draw_polyline(polygon, outline_color, 1.5)
	
	# Vértices arrastáveis
	for i in top_indices:
		var vertex_color = Color.GREEN if vertex_socket_assignments.has(i) else HANDLE_COLOR
		draw_circle(polygon[i], HANDLE_RADIUS_DRAW, vertex_color)
	
	# Desenha linhas de atração para debug (opcional)
	if not game_completed:
		draw_socket_connections()

func draw_socket_connections() -> void:
	for socket in socket_points:
		if not socket.is_occupied:
			# Desenha área de influência
			draw_arc(socket.position, socket_radius, 0, TAU, 32, color_with_alpha(Color.YELLOW, 0.2), 1.0)
			
			# Encontra vértice mais próximo para mostrar atração
			var closest_vertex = -1
			var closest_distance = INF
			
			for i in top_indices:
				if i == dragged_index or vertex_socket_assignments.has(i):
					continue
					
				var distance = polygon[i].distance_to(socket.position)
				if distance < closest_distance and distance < socket_radius:
					closest_distance = distance
					closest_vertex = i
			
			if closest_vertex != -1:
				# Desenha linha de atração
				draw_line(socket.position, polygon[closest_vertex], 
						 color_with_alpha(Color.YELLOW, 0.5), 1.0)

# COMPLEÇÃO
func show_completion() -> void:
	$Label.visible = true
	$Label.text = "🛏 Lençol arrumado!"
	$Label.modulate = Color(0.999, 0.988, 0.994, 1.0)
	print("🏁 Minigame completo!")
	
	await get_tree().create_timer(3.0).timeout
	
	# Despausar o jogo após a compleção
	var cena_subviewport = get_parent().get_parent()
	var cena_principal = cena_subviewport.get_parent().get_parent().get_parent()
	cena_subviewport.get_tree().paused = false
	cena_principal.fechar_subviewport()

# RESET DO JOGO
func reset_minigame() -> void:
	top_indices = get_top_vertices()
	game_completed = false
	
	# Limpa assignments de sockets
	for vertex_index in vertex_socket_assignments:
		var socket = vertex_socket_assignments[vertex_index]
		socket.is_occupied = false
		socket.target_vertex_index = -1
		socket.queue_redraw()
	
	vertex_socket_assignments.clear()
	$Label.visible = false
	queue_redraw()
