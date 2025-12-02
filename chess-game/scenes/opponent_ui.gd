extends Control

signal setup_ready
signal ai_op
signal human_op

@onready var opponent_ui = $"."

func _ready():
	opponent_ui.hide()

func _on_human_button_pressed() -> void:
	emit_signal("human_op")
	emit_signal("setup_ready")
	opponent_ui.hide()


func _on_ai_button_pressed() -> void:
	emit_signal("ai_op")
	emit_signal("setup_ready")
	opponent_ui.hide()


func _on_main_menu_choose_op() -> void:
	opponent_ui.show()
