extends Control

@onready var label = $CanvasLayer/Panel/Label

func set_mission(text):
	label.text = "• " + text
