extends Area2D

# Cor da padrão da pílula
@export var pill_color: String = "AZUL"

# Nó da pílula para o game
signal pill_clicked(pill_node)

func _ready():
	# Input do mouse
	self.input_event.connect(_on_Pill_input_event)

func _on_Pill_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Verifica se foi um clique com o botão esquerdo do mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Marca o clique como "resolvido" para não atravessar para o fundo
		get_viewport().set_input_as_handled()
		
		print("Clique detectado na pílula: ", pill_color)
		
		emit_signal("pill_clicked", self)
