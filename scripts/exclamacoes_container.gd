extends Node2D

@onready var exclamacoes = get_children()
@onready var level_node = get_parent()

func _ready():
	for e in exclamacoes:
		if not e.body_entered.is_connected(_on_exclamacao_body_entered):
			e.body_entered.connect(_on_exclamacao_body_entered)
		e.hide()
		e.get_node("CollisionShape2D").disabled = true

func mostrar_exclamacoes():
	for e in exclamacoes:
		e.show()
		e.get_node("CollisionShape2D").disabled = false
		e.z_index = 100  # garante que apareça acima do mapa/player


func _on_exclamacao_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	
	# a exclamação correta tem o nome "Ecorreta"
	var correta = get_parent().name == "Ecorreta"
	
	if correta:
		await level_node.mostrar_dialogo("Ahh, você me encontrou vovô!", 2.0)
		level_node.finalizar_esconde_esconde()
	else:
		await level_node.mostrar_dialogo("Hmm... ele não está aqui.", 1.5)
