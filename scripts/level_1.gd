extends Node2D

@onready var subviewport_container = $CanvasLayer/SubViewportContainer
@onready var subviewport = $CanvasLayer/SubViewportContainer/SubViewport

@onready var areaPortraitGame = $AreaPortraitGame
@onready var areaBedGame = $AreaBedGame
@onready var areaCookingGame = $AreaCookingGame

var cena_carregada: Node = null

func _ready():
	subviewport_container.visible = false

func _process(_delta):
	# Abre com Q apenas se o player estiver na área
	if areaPortraitGame.player_in_area and Input.is_action_just_pressed("interact"):
		abrir_subviewport("res://scenes/minigamesScenes/Portrait_Puzzle.tscn") ## Caminho Portrait Game
		
	if areaBedGame.player_in_area and Input.is_action_just_pressed("interact"):
		abrir_subviewport("res://scenes/minigamesScenes/Bed_Puzzle.tscn") ## Caminho Bed Game
		
	if areaCookingGame.player_in_area and Input.is_action_just_pressed("interact"):
		abrir_subviewport("res://scenes/minigamesScenes/Bed_Puzzle.tscn") ## Caminho Cooking Game

# Captura todos os inputs de teclado, mesmo com SubViewport ativo
func _input(event):
	if event.is_action_pressed("fechar_viewport") and subviewport_container.visible:
		fechar_subviewport()

func abrir_subviewport(caminho_cena):
	if subviewport_container.visible:
		return
		
	if cena_carregada:
		cena_carregada.queue_free()
		cena_carregada = null
	
	var cena = load(caminho_cena).instantiate()
	subviewport.add_child(cena)
	cena_carregada = cena
	subviewport_container.visible = true

func fechar_subviewport():
	if cena_carregada:
		cena_carregada.queue_free()
		cena_carregada = null
	subviewport_container.visible = false
