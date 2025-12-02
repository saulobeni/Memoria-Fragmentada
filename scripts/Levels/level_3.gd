extends Node2D

var missions = [
	"Arrume a cama",
	"Observe o quadro 
	no quarto",
	"Faça algo para 
	comer",
	"Fale com o seu 
	neto",
	"Tome seus remédios",
	"Vá dormir"
]

var missao_atual = 3

@export var offset_position : Vector2 = Vector2(292,245)
@export var offset_position2 : Vector2 = Vector2(710, 245)

@export var dialog_images1: Array[AtlasTexture] = []
@export var dialog_images2: Array[AtlasTexture] = []

@export var dialog_texts1 : Array[String] = []
@export var dialog_texts2 : Array[String] = []
@export var dialog_texts3 : Array[String] = []
@export var dialog_texts5 : Array[String] = []

@onready var dialog_label = $Player/Camera2D/DialogLabel

@onready var exclamacoes_container = $ObjetosNodes/ExclamacoesContainer

@onready var neto = $ObjetosNodes/Neto
@onready var exclamacoes = $ObjetosNodes/ExclamacoesContainer.get_children()
@onready var ponto_final_neto = $ObjetosNodes/PontoFinalNeto

var fase_neto := false
var id_exclamacao_correta := 2

@onready var subviewport_container = $CanvasLayer/SubViewportContainer
@onready var subviewport = $CanvasLayer/SubViewportContainer/SubViewport

@onready var areaPortraitGame = $AreaPortraitGame
@onready var areaBedGame = $AreaBedGame
@onready var areaCookingGame = $AreaCookingGame
@onready var areaPillGame = $AreaPillGame

@onready var hud = $Hud

@onready var transition_animation = $Transicao/ColorRect/AnimationPlayer

var cena_carregada: Node = null
var paused = false
var pause_menu

var missoesVisitadas = [false,false,false,false, false]
var sequenciaDiaUm = [3,4]
var contadorIdMissao = 0
var cama_pronta_para_dormir = false


func verificar_todas_missoes_completadas():
	for i in range(5):  # Verifica apenas as 5 primeiras missões
		if not missoesVisitadas[i]:
			return false
	return true
	


func _ready():
	transition_animation.play("transicao_vem")
	subviewport_container.visible = false
	
	# Configura a SubViewport para funcionar independentemente
	subviewport_container.set_process_input(true)
	subviewport_container.set_process_unhandled_input(true)
	
	print("SubView size:", $CanvasLayer/SubViewportContainer.size)
	atualizar_missao()
	
	# Corrigido: chama a função correta
	desativar_colisoes()
	mostrar_proxima_missao()
	
	# Carrega o menu de pause
	load_pause_menu()

func _process(_delta):
	
	# -----------------------
	# Interação com o Neto (missão 4)
	# -----------------------
	if fase_neto == false and missao_atual == 3:
			if neto.is_visible_in_tree() and neto.get_node("InteractionArea/CollisionShape2D").disabled == false:
				if Input.is_action_just_pressed("interact"):
					await mostrar_dialogo("Vovô, vamos brincar de esconde-esconde!", 2.0)
					iniciar_esconde_esconde()

	# -----------------------
	# Interação com exclamações (PRESSIONANDO BOTÃO)
	# -----------------------
	if fase_neto and Input.is_action_just_pressed("interact"):
		for e in exclamacoes:
			if e.is_visible_in_tree() and not e.get_node("CollisionShape2D").disabled:
				if e.get_overlapping_bodies().has($Player):
					if e.name == "E%d" % id_exclamacao_correta:
						await mostrar_dialogo("Ahh, você me encontrou vovô!", 2.0)
						finalizar_esconde_esconde()
					else:
						await mostrar_dialogo("Hmm... ele não está aqui.", 1.5)
					return
	
	# -----------------------
	# VERIFICAÇÃO PARA MISSÃO DE DORMIR
	# -----------------------
	if cama_pronta_para_dormir and areaBedGame.player_in_area and Input.is_action_just_pressed("interact"):
		await iniciar_sequencia_sono()
		return
							
	# Verifica interações apenas se o jogo não estiver pausado e a subviewport não estiver visível
	if not paused and not subviewport_container.visible:
		if areaBedGame.player_in_area and Input.is_action_just_pressed("interact") and not cama_pronta_para_dormir:
			$AreaBedGame/CollisionShape2D.disabled = true
			DialogManager.start_dialog(dialog_texts1, global_position + offset_position, dialog_images1, $Player)
			await DialogManager.dialog_completed
			abrir_subviewport("res://scenes/minigamesScenes/BedGame/Bed_Puzzle_Hard.tscn")
			if not missoesVisitadas[0]:  # Corrigido: removido == false
				# Só avança se esta for a missão atual na sequência
				if contadorIdMissao > 0 && sequenciaDiaUm[contadorIdMissao - 1] == 0:
					mostrar_proxima_missao()
				missoesVisitadas[0] = true
				# NÃO desativa permanentemente a colisão da cama
				# areaBedGame.get_node("CollisionShape2D").disabled = true
			proxima_missao()
			
			# Verifica se todas as missões foram completadas após cada minigame
			if verificar_todas_missoes_completadas():
				ativar_missao_dormir()
				
		if areaPortraitGame.player_in_area and Input.is_action_just_pressed("interact"):
			$AreaPortraitGame/CollisionShape2D.disabled = true
			DialogManager.start_dialog(dialog_texts2, global_position + offset_position, dialog_images2, $Player)
			await DialogManager.dialog_completed
			abrir_subviewport("res://scenes/minigamesScenes/PortraitGame/Portrait_Puzzle_Hard.tscn")
			if not missoesVisitadas[1]:  # Corrigido: removido == false
				# Só avança se esta for a missão atual na sequência
				if contadorIdMissao > 0 && sequenciaDiaUm[contadorIdMissao - 1] == 1:
					mostrar_proxima_missao()
				missoesVisitadas[1] = true
				areaPortraitGame.get_node("CollisionShape2D").disabled = true
			proxima_missao()
			
			# Verifica se todas as missões foram completadas após cada minigame
			if verificar_todas_missoes_completadas():
				ativar_missao_dormir()
				
		if areaCookingGame.player_in_area and Input.is_action_just_pressed("interact"):
			$AreaCookingGame/CollisionShape2D.disabled = true
			DialogManager.start_dialog(dialog_texts3, global_position+offset_position2, dialog_images2, $Player)
			await DialogManager.dialog_completed
			abrir_subviewport("res://scenes/minigamesScenes/CookingGame/Cooking_Puzzle.tscn")
			if not missoesVisitadas[2]:  # Corrigido: removido == false
				# Só avança se esta for a missão atual na sequência
				if contadorIdMissao > 0 && sequenciaDiaUm[contadorIdMissao - 1] == 2:
					mostrar_proxima_missao()
				missoesVisitadas[2] = true
				areaCookingGame.get_node("CollisionShape2D").disabled = true
			proxima_missao()
			
			# Verifica se todas as missões foram completadas após cada minigame
			if verificar_todas_missoes_completadas():
				ativar_missao_dormir()
				
		if areaPillGame.player_in_area and Input.is_action_just_pressed("interact"):
			abrir_subviewport("res://scenes/minigamesScenes/PillGame/GameScene_Hard.tscn")
			if not missoesVisitadas[4]:  # Corrigido: removido == false
				# Só avança se esta for a missão atual na sequência
				if contadorIdMissao > 0 && sequenciaDiaUm[contadorIdMissao - 1] == 4:
					mostrar_proxima_missao()
				missoesVisitadas[4] = true
				areaPillGame.get_node("CollisionShape2D").disabled = true
			proxima_missao()
			
			# Verifica se todas as missões foram completadas após cada minigame
			if verificar_todas_missoes_completadas():
				ativar_missao_dormir()

func abrir_minigame(area_info: Dictionary):
	abrir_subviewport(area_info.cena)
	
	# CORREÇÃO: Use = em vez de == para atribuição
	if not missoesVisitadas[area_info.index]:
		missoesVisitadas[area_info.index] = true  # CORREÇÃO AQUI
		area_info.area.get_node("CollisionShape2D").disabled = true
		
		# Avança para próxima missão apenas se esta for a atual
		if sequenciaDiaUm[contadorIdMissao] == area_info.index:
			mostrar_proxima_missao()

func mostrar_proxima_missao():
	if contadorIdMissao < sequenciaDiaUm.size():
		var proxima_missao_id = sequenciaDiaUm[contadorIdMissao]
		var area = representar_missao(proxima_missao_id)
		
		if area:
			area.get_node("CollisionShape2D").disabled = false
			print("Missão ativada: ID ", proxima_missao_id, " - ", area.name)
		
		contadorIdMissao += 1
	else:
		print("Todas as missões foram completadas!")

func desativar_colisoes():
	for child in get_children():
		if child.get_class() == "Area2D":
			child.get_node("CollisionShape2D").disabled = true

func representar_missao(id):
	if id == 0:
		return areaBedGame
	elif id == 1:
		return areaPortraitGame
	elif id == 2:
		return areaCookingGame
	elif id == 4:
		return areaPillGame
	else:
		return null

func atualizar_missao():
	if missao_atual < missions.size():
		hud.set_mission(missions[missao_atual])
	else:
		hud.set_mission("Todas as tarefas 
		do dia foram 
		concluídas")

func proxima_missao():
	missao_atual += 1
	atualizar_missao()

func _input(event):
	if event.is_action_pressed("fechar_viewport") and subviewport_container.visible:
		fechar_subviewport()
	elif event.is_action_pressed("ui_cancel") and not subviewport_container.visible:
		toggle_pause()

func abrir_subviewport(caminho_cena):
	if subviewport_container.visible:
		return
		
	if cena_carregada:
		cena_carregada.queue_free()
		cena_carregada = null
		
	if caminho_cena.contains("Portrait_Puzzle") or caminho_cena.contains("PillGame"):
		subviewport.transparent_bg = true
	else:
		subviewport.transparent_bg = false
	
	var cena = load(caminho_cena).instantiate()
	subviewport.add_child(cena)
	cena_carregada = cena
	subviewport_container.visible = true
	
	# Configura TODOS os nós da cena carregada para processar mesmo se o jogo estiver pausado
	configurar_processamento_recursivo(cena_carregada, Node.PROCESS_MODE_ALWAYS)
	
	# Configura a SubViewportContainer para capturar inputs
	subviewport_container.process_mode = Node.PROCESS_MODE_ALWAYS
	subviewport_container.set_process_input(true)
	subviewport_container.set_process_unhandled_input(true)
	subviewport_container.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Configura a SubViewport para não ser afetada pela pausa
	subviewport.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Foca na SubViewport para receber inputs
	subviewport_container.grab_focus()
	
	print("SubViewport aberta - Inputs devem funcionar")

# Função recursiva para configurar o process_mode de todos os nós
func configurar_processamento_recursivo(node: Node, process_mode: Node.ProcessMode):
	node.process_mode = process_mode
	for child in node.get_children():
		configurar_processamento_recursivo(child, process_mode)

func fechar_subviewport():
	if cena_carregada:
		cena_carregada.queue_free()
		cena_carregada = null
	
	subviewport_container.visible = false
	
	# Retoma o mundo principal
	get_tree().paused = false
	paused = false
	
	# Restaura o foco para a viewport principal
	get_viewport().gui_release_focus()

func load_pause_menu():
	# Cria o menu de pause programaticamente
	pause_menu = CanvasLayer.new()
	pause_menu.name = "PauseMenu"
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Fundo semi-transparente
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Painel centralizado manualmente (mais confiável)
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(350, 300)
	panel.add_theme_stylebox_override("panel", create_panel_stylebox())
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Centraliza manualmente
	var screen_size = get_viewport().get_visible_rect().size
	panel.position = Vector2(
		(screen_size.x - panel.custom_minimum_size.x) / 2,
		(screen_size.y - panel.custom_minimum_size.y) / 2
	)
	
	# Container com margens
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	margin_container.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# VBoxContainer para os botões
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Título
	var title = Label.new()
	title.text = "JOGO PAUSADO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.WHITE)
	
	# Botão Continuar
	var resume_btn = Button.new()
	resume_btn.text = "Continuar"
	resume_btn.custom_minimum_size = Vector2(250, 50)
	resume_btn.pressed.connect(_on_resume_pressed)
	resume_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	setup_button_style(resume_btn)
	
	# Botão Reiniciar
	var restart_btn = Button.new()
	restart_btn.text = "Reiniciar"
	restart_btn.custom_minimum_size = Vector2(250, 50)
	restart_btn.pressed.connect(_on_restart_pressed)
	restart_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	setup_button_style(restart_btn)
	
	# Botão Sair
	var quit_btn = Button.new()
	quit_btn.text = "Sair"
	quit_btn.custom_minimum_size = Vector2(250, 50)
	quit_btn.pressed.connect(_on_quit_pressed)
	quit_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	setup_button_style(quit_btn)
	
	# Adiciona elementos
	vbox.add_child(title)
	vbox.add_child(create_spacer(30))
	vbox.add_child(resume_btn)
	vbox.add_child(create_spacer(15))
	vbox.add_child(restart_btn)
	vbox.add_child(create_spacer(15))
	vbox.add_child(quit_btn)
	
	# Centraliza o VBoxContainer
	var vbox_center = CenterContainer.new()
	vbox_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox_center.process_mode = Node.PROCESS_MODE_ALWAYS
	vbox_center.add_child(vbox)
	
	# Monta hierarquia
	margin_container.add_child(vbox_center)
	panel.add_child(margin_container)
	background.add_child(panel)
	pause_menu.add_child(background)
	add_child(pause_menu)
	
	pause_menu.hide()

func create_panel_stylebox() -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	stylebox.border_color = Color.BLACK
	stylebox.border_width_left = 4
	stylebox.border_width_top = 4
	stylebox.border_width_right = 4
	stylebox.border_width_bottom = 4
	stylebox.corner_radius_top_left = 15
	stylebox.corner_radius_top_right = 15
	stylebox.corner_radius_bottom_right = 15
	stylebox.corner_radius_bottom_left = 15
	stylebox.shadow_color = Color(0, 0, 0, 0.5)
	stylebox.shadow_size = 15
	return stylebox

func setup_button_style(button: Button):
	button.add_theme_font_size_override("font_size", 18)
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	normal_style.border_color = Color.BLACK
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.3, 0.3, 1.0)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", hover_style)
	
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)

func create_spacer(height: int) -> Control:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	return spacer

func toggle_pause():
	# Não permite pausar se a subviewport estiver aberta
	if subviewport_container.visible:
		return
		
	paused = !paused
	get_tree().paused = paused
	
	if paused:
		pause_menu.show()
	else:
		pause_menu.hide()

func _on_resume_pressed():
	toggle_pause()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
	
# -----------------------
# TRANSIÇÃO NETO
# -----------------------
func iniciar_esconde_esconde() -> void:
	fase_neto = true
	
	transition_animation.play("transicao_vai")
	await get_tree().create_timer(1.0).timeout
	
	neto.hide()
	
	transition_animation.play("transicao_vem")
	await get_tree().create_timer(0.5).timeout
	
	exclamacoes_container.mostrar_exclamacoes()

	for e in exclamacoes:
		e.show()
		e.get_node("AnimationPlayer").play("pular")


func finalizar_esconde_esconde() -> void:
	transition_animation.play("transicao_vai")
	await get_tree().create_timer(1.0).timeout
	
	exclamacoes_container.esconder_exclamacoes()
	
	# Coloca o neto diretamente no ponto desejado
	neto.position = $SpawnNeto.position
	neto.show()
	
	transition_animation.play("transicao_vem")
	await get_tree().create_timer(0.5).timeout
	
	await mostrar_dialogo("Parabéns! Você me encontrou!", 2.0)
	
	fase_neto = false
	proxima_missao()
	
	# MARCA A MISSÃO 3 (NETO) COMO CONCLUÍDA
	if not missoesVisitadas[3]:
		missoesVisitadas[3] = true
		print("Missão do neto concluída!")
	
	areaPillGame.get_node("CollisionShape2D").disabled = false
	
	# VERIFICA SE TODAS AS MISSÕES FORAM COMPLETADAS
	if verificar_todas_missoes_completadas():
		ativar_missao_dormir()
		
func ativar_missao_dormir():
	print("Todas as missões completadas! Ativando missão 'Vá dormir'...")
	
	# Ativa a colisão da cama novamente
	areaBedGame.get_node("CollisionShape2D").disabled = false
	cama_pronta_para_dormir = true
	
	# Atualiza a missão atual para a 6ª
	missao_atual = 5  # Índice 5 = "Vá dormir"
	atualizar_missao()
	
	# Chama uma função no AreaBedGame para atualizar o texto
	if has_node("AreaBedGame"):
		# Marca que a cama está pronta para dormir
		areaBedGame.get_node("Label").text = "Pressione Q"
		
func iniciar_sequencia_sono():
	print("Iniciando sequência de sono...")
	
	# Desativa o jogador
	$Player/CollisionShape2D.disabled = true
	$Player/AnimatedSprite2D.play("idle")  # Ou animação de dormir
	
	# Mostra diálogo
	await mostrar_dialogo("Estou cansado...", 2.0)
	
	# Fade out
	transition_animation.play("transicao_vai")
	await get_tree().create_timer(1.0).timeout
	
	# Carrega o dia 2
	get_tree().change_scene_to_file("res://scenes/FIM_DE_JOGO.tscn")


func _on_InteractionArea_body_entered(body):
	if body.name != "Player":
		return

	var level_node = get_parent()  # Level1 é o pai
	if not level_node.fase_neto:
		await level_node.mostrar_dialogo("Vovô, vamos brincar de esconde-esconde!", 2.0)
		level_node.iniciar_esconde_esconde()

func mostrar_dialogo(texto: String, duracao: float = 2.0) -> void:
	dialog_label.text = texto
	dialog_label.show()
	# Esconde após X segundos
	await get_tree().create_timer(duracao).timeout
	dialog_label.hide()


func _on_ecorreta_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
		
	await mostrar_dialogo("Finalmente achei você,\n       netinho!", 2.0)


	
