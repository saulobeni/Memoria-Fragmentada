extends Area2D

var player_in_area := false
# Adicione esta variável para controlar se a cama já foi arrumada
var cama_arrumada = false

func _ready():
	# Apenas para debug visual
	$Label.text = ""

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		
		# Verifica se já pode dormir (vindo da cena principal)
		var level_node = get_parent()
		if level_node and level_node.has_method("verificar_todas_missoes_completadas"):
			if level_node.verificar_todas_missoes_completadas():
				$Label.text = "Dormir (Q)"
			else:
				$Label.text = "Pressione 'Q'"
		else:
			$Label.text = "Pressione 'Q'"

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		$Label.text = ""
