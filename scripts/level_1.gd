extends Node2D

@onready var subviewport_container = $CanvasLayer/SubViewportContainer
@onready var subviewport = $CanvasLayer/SubViewportContainer/SubViewport
@onready var area_interacao = $Area2D

var cena_carregada: Node = null

func _ready():
	subviewport_container.visible = false

func _process(_delta):
	# Abre com Q apenas se o player estiver na área
	if area_interacao.player_in_area and Input.is_action_just_pressed("interact"):
		abrir_subviewport()

## NECESSIDADE DE AJEITAR ---> FUNÇÃO: APERTAR "ESC" E SAIR DO MINIGAME
# Captura todos os inputs de teclado, mesmo com SubViewport ativo
func _input(event):
	if event.is_action_pressed("fechar_viewport") and subviewport_container.visible:
		fechar_subviewport()

func abrir_subviewport():
	if subviewport_container.visible:
		return
	var cena = load("res://scenes/minigamesScenes/Portrait_Puzzle.tscn").instantiate()
	subviewport.add_child(cena)
	cena_carregada = cena
	subviewport_container.visible = true

func fechar_subviewport():
	if cena_carregada:
		cena_carregada.queue_free()
		cena_carregada = null
	subviewport_container.visible = false
