extends Node2D

@onready var world: Node = $World
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D

var house_scene := preload("res://House/house.tscn")
var house_instance: Node = null

func _ready() -> void:
	# Instancia e adiciona a casa no mundo
	house_instance = house_scene.instantiate()
	world.add_child(house_instance)

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
