extends Control

@export var rows: int = 3
@export var columns: int = 3
@export var piece_size: Vector2 = Vector2(341, 341)
@export var portrait_path: String = "res://assets/textures/minigame_quadro/portrait_sem_borda.png"

@onready var puzzle_area: Control = $PuzzleArea
@onready var pieces_container: Node = $PuzzleArea/Pieces
@onready var bg: Control = $Bg

var pieces: Array = []
var selected_piece: TextureRect = null
var grid_positions: Array = []
var correct_positions: Array = []
var puzzle_completed := false


func _ready():
	await get_tree().process_frame
	scale = Vector2(0.3, 0.3)  # exemplo, você pode ajustar
	
	var total_rect = get_total_bounds(self)
	
	generate_puzzle()


func generate_puzzle():
	clear_children()
	pieces.clear()
	grid_positions.clear()
	correct_positions.clear()
	puzzle_completed = false

	var portrait = load(portrait_path)
	if portrait == null:
		push_error("Portrait image not found at: %s" % portrait_path)
		return

	# --- CENTRALIZA O PUZZLE DENTRO DA MOLDURA ---
	var total_width = columns * (piece_size.x + 5)
	var total_height = rows * (piece_size.y + 5)


	# --- CRIA AS PEÇAS ---
	for row in range(rows):
		for col in range(columns):
			var piece = TextureRect.new()
			piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			piece.custom_minimum_size = piece_size
			piece.set_size(piece_size)

			var region = Rect2(col * piece_size.x, row * piece_size.y, piece_size.x, piece_size.y)
			var texture = AtlasTexture.new()
			texture.atlas = portrait
			texture.region = region
			piece.texture = texture

			piece.connect("gui_input", Callable(self, "_on_piece_input").bind(piece))

			# adiciona dentro do node "Pieces"
			puzzle_area.add_child(piece)

			var grid_pos = Vector2(col, row)
			correct_positions.append(grid_pos)
			grid_positions.append(grid_pos)
			pieces.append(piece)

	# embaralha posições
	grid_positions.shuffle()
	position_pieces()


func clear_children():
	for child in pieces_container.get_children():
		child.queue_free()


func position_pieces():
	for i in range(pieces.size()):
		var grid_pos = grid_positions[i]
		var piece = pieces[i]

		# posição relativa à área do puzzle (já centralizada)
		var pos = Vector2(
			grid_pos.x * (piece_size.x + 5),
			grid_pos.y * (piece_size.y + 5)
		)

		piece.position = pos


func _on_piece_input(event: InputEvent, piece: TextureRect):
	if puzzle_completed:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_piece == null:
			selected_piece = piece
			selected_piece.modulate = Color(1, 1, 0.7) # destaque
		else:
			var index1 = pieces.find(selected_piece)
			var index2 = pieces.find(piece)
			if index1 != -1 and index2 != -1:
				var temp = grid_positions[index1]
				grid_positions[index1] = grid_positions[index2]
				grid_positions[index2] = temp

				position_pieces()
				check_victory()

			selected_piece.modulate = Color(1, 1, 1)
			selected_piece = null


func check_victory():
	for i in range(grid_positions.size()):
		if grid_positions[i] != correct_positions[i]:
			return

	# completo!
	puzzle_completed = true

	for piece in pieces:
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE

	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")
	
func get_total_bounds(node):
	var rect := Rect2()
	var first := true

	for child in node.get_children():
		if child is Control:
			var global_pos = child.get_global_position()
			var scale_factor = child.get_global_transform().get_scale()
			var size = child.size * scale_factor

			if first:
				rect = Rect2(global_pos, size)
				first = false
			else:
				rect = rect.expand(global_pos)
				rect = rect.expand(global_pos + size)

		return rect
