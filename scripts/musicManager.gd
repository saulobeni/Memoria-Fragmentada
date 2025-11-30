extends Node

var player: AudioStreamPlayer

const MUSIC_PATH := "res://assets/sounds/dramatic-flute-for-documentaries-165986.mp3"

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load(MUSIC_PATH)
	player.autoplay = false
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS


func play():
	if not player.playing:
		player.play()


func stop():
	player.stop()


func set_enabled(enabled: bool):
	if enabled:
		player.volume_db = 0
	else:
		player.volume_db = -80
