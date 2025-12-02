extends Node2D

# A ordem correta que o jogador deve seguir
const CORRECT_ORDER: Array[String] = ["AZUL", "ROXA", "VERDE", "VERMELHA", "BRANCA", "AMARELA"]
var current_step: int = 0
var game_active: bool = false

@onready var neto_text: Label = $NetoText
@onready var pill_container: Node2D = $PillsContainer

func _ready():
	# Adiciona fundo branco
	adicionar_fundo_branco()
	
	# Configura a cor do texto do Neto para preto
	configurar_texto_preto()
	
	# Conecta o sinal de todas as pílulas que estão dentro da pasta PillsContainer
	for pill in pill_container.get_children():
		# Verifica se o objeto tem o sinal que criamos para evitar erros
		if pill.has_signal("pill_clicked"):
			pill.pill_clicked.connect(_on_pill_clicked)
			
	start_minigame()

func adicionar_fundo_branco():
	"""Adiciona um fundo branco ao minigame"""
	var background = ColorRect.new()
	background.name = "WhiteBackground"
	background.color = Color.WHITE
	
	# IMPORTANTE: Desabilita a detecção de input/mouse para o fundo
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Configura o tamanho
	background.size = get_viewport_rect().size
	
	# Usa ancoras para cobrir toda a tela
	background.anchor_left = 0
	background.anchor_top = 0
	background.anchor_right = 1
	background.anchor_bottom = 1
	background.grow_horizontal = Control.GROW_DIRECTION_BOTH
	background.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	# Z-index negativo para ficar atrás
	background.z_index = -1
	
	add_child(background)
	move_child(background, 0)  # Move para ser o primeiro nó (fundo)

func configurar_texto_preto():
	"""Configura a cor do texto do Neto para preto"""
	if neto_text:
		# Método mais simples e direto
		neto_text.add_theme_color_override("font_color", Color.BLACK)
		
		# Ou use self_modulate se o método acima não funcionar
		# neto_text.self_modulate = Color.BLACK

func start_minigame():
	current_step = 0
	game_active = true
	
	# Reinicia o jogo mostrando todas as pílulas novamente
	for pill in pill_container.get_children():
		if pill is Area2D:
			pill.show()
			
	next_step()

func next_step():
	# Verifica se ainda há remédios na lista para tomar
	if current_step < CORRECT_ORDER.size():
		var required_color = CORRECT_ORDER[current_step]
		neto_text.text = "Neto: Agora tome o remédio " + required_color + "!"
	else:
		# Fim do jogo
		neto_text.text = "Neto: Perfeito, Vovô!\n Todas no horário certo!"
		game_active = false
		print("Minigame Concluído com Sucesso!")
		
		await get_tree().create_timer(3.0).timeout
		# Despausar o jogo após a compleção
		var cena_subviewport = get_parent().get_parent()
		var cena_principal = cena_subviewport.get_parent().get_parent()
		cena_subviewport.get_tree().paused = false
		cena_principal.fechar_subviewport()

# Esta função recebe a Pílula inteira que foi clicada
func _on_pill_clicked(clicked_pill):
	if not game_active:
		return

	# Pega a cor que está configurada na pílula clicada
	var clicked_color = clicked_pill.pill_color
	# Vê qual é a cor necessária nesta etapa
	var required_color = CORRECT_ORDER[current_step]

	if clicked_color == required_color:
		# ACERTO:
		print("ACERTOU! Cor: " + clicked_color)
		clicked_pill.hide()  # Esconde a pílula
		current_step += 1 # Avança para o próximo passo
		
		# Espera 0.5 segundos para dar tempo de ler/ver antes de mudar a fala
		await get_tree().create_timer(0.5).timeout
		next_step()
		
	else:
		# ERROU:
		print("ERROU! Clicou em: " + clicked_color)
		# AQUI a pílula NÃO se esconde. Apenas o texto muda avisando o erro.
		neto_text.text = "Neto: Opa, Vovô... não é o " + clicked_color + ". É o " + required_color + "!"
