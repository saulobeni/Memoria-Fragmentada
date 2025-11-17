extends Node2D

@onready var world: Node = $World
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var ambient_sound: AudioStreamPlayer = $AmbientSound

var house_scene := preload("res://scenes/house.tscn")
var house_instance: Node = null

func _ready() -> void:
	# --- INICIA O SOM AMBIENTE ---
	_start_ambient_sound()
	
	# Instancia e adiciona a casa no mundo
	house_instance = $House
	
	# Espera um frame para garantir que os nodes internos existam
	await get_tree().process_frame
	
	# --- PEGAR O SPAWN ---
	var spawn_path := "SpawnPoints/PlayerSpawn"
	if house_instance.has_node(spawn_path):
		var spawn: Node2D = house_instance.get_node(spawn_path)
		player.global_position = spawn.global_position
	else:
		push_warning("SpawnPoints/PlayerSpawn não encontrado em house_instance")
	
	# --- PEGAR O TILEMAP da casa para configurar limites da câmera ---
	var tilemap_node_name := "TileMap"
	if house_instance.has_node(tilemap_node_name):
		var map := house_instance.get_node(tilemap_node_name) as TileMap
		if map:
			var used_rect: Rect2i = map.get_used_rect()
			var cell_size: Vector2 = map.tile_set.tile_size if map.tile_set else Vector2(64, 64)
			
			camera.limit_left = used_rect.position.x * cell_size.x
			camera.limit_top = used_rect.position.y * cell_size.y
			camera.limit_right = used_rect.end.x * cell_size.x
			camera.limit_bottom = used_rect.end.y * cell_size.y
		else:
			push_warning("O nó TileMap não é um TileMap válido")
	else:
		push_warning("TileMap não encontrado dentro da house_instance")

func _start_ambient_sound() -> void:
	if is_instance_valid(ambient_sound):
		# Configura o som para loop
		if ambient_sound.stream:
			# Se for um AudioStreamWAV ou AudioStreamOggVorbis, ativa o loop
			if ambient_sound.stream is AudioStreamWAV:
				ambient_sound.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			elif ambient_sound.stream is AudioStreamOggVorbis:
				ambient_sound.stream.loop = true
		
		# Conecta o sinal de finished para reiniciar o som
		if not ambient_sound.finished.is_connected(_on_ambient_sound_finished):
			ambient_sound.finished.connect(_on_ambient_sound_finished)
		
		# Inicia o som
		ambient_sound.play()
	else:
		push_warning("AmbientSound não encontrado. Adicione um AudioStreamPlayer como filho desta cena.")

func _on_ambient_sound_finished() -> void:
	# Reinicia o som quando terminar
	if is_instance_valid(ambient_sound):
		ambient_sound.play()

func _on_interact_with_portrait():
	var puzzle_scene = preload("res://scenes/minigamesScenes/Portrait_Puzzle.tscn").instantiate()
	get_tree().root.add_child(puzzle_scene)
	puzzle_scene.show()
