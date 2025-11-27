extends Node2D

@onready var exclamacoes: Array = get_children()
@onready var level_node = get_parent()

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
