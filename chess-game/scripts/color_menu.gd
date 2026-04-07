extends Control

@onready var continue_button: Button = $Continue_Button

var load_scene

var choice : String
var victory : bool

func _ready() -> void:
	randomize()
	continue_button.hide()

func _on_heads_button_pressed() -> void:
	choice = "heads"
	flip()

func _on_tails_button_pressed() -> void:
	choice = "tails"
	flip()
	
func flip() -> void:
	var roll = randf()
	if roll < 0.5 and choice == "heads":
		print("you won")
		victory = true
	elif roll >= 0.5 and choice == "tails":
		print("you won")
		victory = true
	else:
		print("you lost")
		victory = false
	
	continue_button.show()


func _on_continue_button_pressed() -> void:
	if victory:
		load_scene.ai_color = Globals.COLORS.BLACK
	else:
		load_scene.ai_color = Globals.COLORS.WHITE
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(load_scene)
	get_tree().current_scene = load_scene
	SignalBus.emit_signal("change_map", load_scene.current_map)
