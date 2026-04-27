extends Node

const SYOUKI_TAKAHASHI_MENU = preload("res://Assets/Sounds/Music/syouki_takahashi-strategist-1-220873.mp3")
const SYOUKI_TAKAHASHI_GAMEPLAY = preload("res://Assets/Sounds/Music/syouki_takahashi-strategist-2-250338.mp3")

var audio_player : AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Music"
	add_child(audio_player)
	play_music(SYOUKI_TAKAHASHI_MENU)

func play_music(stream : AudioStream) -> void:
	if audio_player.playing:
		audio_player.stop()
	audio_player.stream = stream
	audio_player.volume_db = linear_to_db(0.5)
	audio_player.play()

func play_menu() -> void:
	play_music(SYOUKI_TAKAHASHI_MENU)

func play_game() -> void:
	play_music(SYOUKI_TAKAHASHI_GAMEPLAY)
