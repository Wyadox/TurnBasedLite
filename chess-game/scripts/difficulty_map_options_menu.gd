extends Control

var difficulty : int = -1
var map : int = -1

func _on_easy_button_pressed() -> void:
	difficulty = 0

func _on_normal_button_pressed() -> void:
	difficulty = 1

func _on_hard_button_pressed() -> void:
	difficulty = 2

func _on_map_1_button_pressed() -> void:
	map = 1

func _on_map_2_button_pressed() -> void:
	map = 2

func _on_map_3_button_pressed() -> void:
	map = 3

func _on_map_4_button_pressed() -> void:
	map = 4


func _on_easy_button_button_up() -> void:
	play_button_sound()


func _on_normal_button_button_up() -> void:
	play_button_sound()


func _on_hard_button_button_up() -> void:
	play_button_sound()

func play_button_sound() -> void:
	var audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	audioPlayer.stream = preload("res://Assets/Sounds/button_click_cropped.mp3")
	audioPlayer.volume_db = linear_to_db(0.5)
	audioPlayer.play()
	audioPlayer.finished.connect(audioPlayer.queue_free)
