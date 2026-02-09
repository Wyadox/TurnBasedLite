extends Control

var option

func _ready() -> void:
	tree_exited.connect(_on_tree_exited)

func _on_human_button_pressed() -> void:
	option = "human"
	SignalBus.emit_signal("test", "hi")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	SignalBus.emit_signal("human_op")


func _on_ai_button_pressed() -> void:
	option = "ai"
	SignalBus.emit_signal("ai_op")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_tree_exited():
	if option == "human":
		SignalBus.emit_signal("human_op")
		print("human_op emit")
	else:
		SignalBus.emit_signal("ai_op")
		print("ai_op emit")
