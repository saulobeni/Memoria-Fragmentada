extends Control

@export var rows: int = 3
@export var columns: int = 3
@export var piece_size: Vector2 = Vector2(128, 128)
@export var portrait_path: String = "res://assets/textures/minigame_quadro/portrait.png"

var pieces: Array = []
var selected_piece: TextureRect = null
var grid_positions: Array = []
var correct_positions: Array = []
var puzzle_completed := false

func _ready():
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
			add_child(piece)

			var grid_pos = Vector2(col, row)
			correct_positions.append(grid_pos)
			grid_positions.append(grid_pos)
			pieces.append(piece)

	grid_positions.shuffle()
	position_pieces()

func clear_children():
	for child in get_children():
		child.queue_free()

func position_pieces():
	for i in range(pieces.size()):
		var grid_pos = grid_positions[i]
		var piece = pieces[i]
		piece.position = Vector2(grid_pos.x * (piece_size.x + 5), grid_pos.y * (piece_size.y + 5))

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
			return # Ainda não completo

	# Se chegou aqui, está completo 🎉
	puzzle_completed = true
	show_victory_message()

func show_victory_message():
	var label = Label.new()
	label.text = "🧩 Quebra-cabeça completo!"
	label.modulate = Color(0, 1, 0)
	label.add_theme_font_size_override("font_size", 32)
	label.position = Vector2(100, 100)
	add_child(label)

	# Desativar cliques nas peças
	for piece in pieces:
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
