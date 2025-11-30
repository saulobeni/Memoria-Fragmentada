extends Node2D

@onready var exclamacoes: Array = get_children()
@onready var level_node = get_parent().get_parent()

func _ready():
	for e in exclamacoes:
		e.hide()
		e.get_node("CollisionShape2D").disabled = true

func mostrar_exclamacoes():
	for e in exclamacoes:
		e.show()
		e.get_node("CollisionShape2D").disabled = false
		e.z_index = 100

func esconder_exclamacoes():
	for e in exclamacoes:
		e.hide()
		e.get_node("CollisionShape2D").disabled = true

# FUNCAO CASO SEJA MELHOR APARECER O DIALOGO QUANDO SE APROXIMAR DO LOCAL ESCONDIDO
#func _on_body_entered(body: Node2D) -> void:
#	if body.name != "Player":
#		return
	
	await level_node.mostrar_dialogo("       Hmm...\nele não está aqui.", 1.5)
