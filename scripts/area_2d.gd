extends Area2D

var player_in_area := false

func _ready():
	# Apenas para debug visual
	$Label.text = ""

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		$Label.text = "Pressione 'Q'"

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		$Label.text = ""
