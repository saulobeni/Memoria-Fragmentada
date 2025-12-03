extends Node2D

@onready var spawner = $FruitSpawner
@onready var container = $FruitContainer
@export var fruit_scene: PackedScene
@onready var message_label = $MessageLabel

# Adicione um Label na cena e nomeie como CounterLabel
@onready var counter_label = $CounterLabel

var fruits_cut := 0
var fruits_required := 10  # Meta de frutas para cortar
var game_active := true
var spawn_timer: Timer

func _ready():
	message_label.visible = false
	
	# Configura o contador - certifique-se de adicionar um Label chamado "CounterLabel" na cena
	if counter_label:
		counter_label.text = "Ingredientes: 0/" + str(fruits_required)
		counter_label.visible = true
	else:
		# Se não tiver counter_label, cria um dinamicamente
		create_counter_label()
	
	# Cria um timer para spawn contínuo
	spawn_timer = Timer.new()
	spawn_timer.wait_time = randf_range(1.0, 1.8)  # Intervalo entre spawns
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Inicia o spawn
	spawn_fruit()
	spawn_timer.start()

func create_counter_label():
	# Cria um Label dinamicamente se não existir na cena
	var new_label = Label.new()
	new_label.name = "CounterLabel"
	new_label.text = "Ingredientes: 0/" + str(fruits_required)
	new_label.visible = true
	
	# Posiciona no canto superior esquerdo
	new_label.position = Vector2(20, 20)
	
	# Estilização básica
	new_label.add_theme_font_size_override("font_size", 32)
	new_label.add_theme_color_override("font_color", Color.WHITE)
	new_label.add_theme_color_override("font_outline_color", Color.BLACK)
	new_label.add_theme_constant_override("outline_size", 2)
	
	add_child(new_label)
	counter_label = new_label

func _on_spawn_timer_timeout():
	if game_active and container.get_child_count() < 15:  # Limite de frutas na tela
		spawn_fruit()
	
	# Configura próximo timer com tempo aleatório
	spawn_timer.wait_time = randf_range(0.8, 1.5)
	spawn_timer.start()

func spawn_fruit():
	if not game_active:
		return
	
	var fruit = fruit_scene.instantiate()
	
	# Posição aleatória no topo da tela
	fruit.position = Vector2(randf_range(150, 650), -30)  # Começa acima da tela
	
	# Conecta o sinal de fruta cortada
	if fruit.has_signal("fruit_cut"):
		fruit.connect("fruit_cut", Callable(self, "_on_fruit_cut"))
	else:
		# Se a fruta não tem o sinal, conecta via área
		fruit.set_meta("was_cut", false)
		var fruit_area = fruit.get_node("Area2D")
		if fruit_area and not fruit_area.is_connected("area_entered", Callable(self, "_on_fruit_hit")):
			fruit_area.connect("area_entered", Callable(self, "_on_fruit_hit").bind(fruit))
	
	# Conecta para saber quando fruta é removida
	if not fruit.is_connected("tree_exited", Callable(self, "_on_fruit_exited")):
		fruit.connect("tree_exited", Callable(self, "_on_fruit_exited").bind(fruit))
	
	container.add_child(fruit)

func _on_fruit_cut():
	if not game_active:
		return
	
	fruits_cut += 1
	
	# Atualiza o contador na tela
	if counter_label:
		counter_label.text = "Ingredientes: " + str(fruits_cut) + "/" + str(fruits_required)
	
	print("Ingredientes cortadas: ", fruits_cut, "/", fruits_required)
	
	# Verifica se atingiu a meta
	if fruits_cut >= fruits_required:
		end_minigame_success()

func _on_fruit_hit(area, fruit):
	if area.name == "Knife" and not fruit.get_meta("was_cut") and game_active:
		fruit.set_meta("was_cut", true)
		_on_fruit_cut()  # Chama a mesma função de corte

func _on_fruit_exited(fruit):
	# Esta função ainda é chamada quando frutas são removidas
	# Mas não afeta mais a lógica de término do jogo
	pass

func end_minigame_success():
	game_active = false
	
	# Para o timer de spawn
	if spawn_timer:
		spawn_timer.stop()
	
	# Esconde o contador
	if counter_label:
		counter_label.visible = false
	
	show_message("🎉 MISSÃO CONCLUÍDA! 🎉\n" + str(fruits_cut) + " ingredientes cortados!")
	
	# Espera 3 segundos e fecha
	await get_tree().create_timer(3.0).timeout
	
	# Fecha a SubViewport
	var cena_subviewport = get_parent().get_parent()
	var cena_principal = cena_subviewport.get_parent().get_parent()
	cena_principal.fechar_subviewport()

func show_message(text):
	message_label.text = text
	message_label.visible = true
	message_label.modulate.a = 0.0
	message_label.scale = Vector2(0.6, 0.6)

	# Animação suave
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(message_label, "scale", Vector2(1,1), 0.6).set_trans(Tween.TRANS_BACK)
