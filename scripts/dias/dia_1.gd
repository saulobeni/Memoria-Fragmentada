extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	anim.play("fade_transition")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")
