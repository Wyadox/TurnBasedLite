extends Control

var choice : String

func _ready() -> void:
	randomize()

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
	elif roll >= 0.5 and choice == "tails":
		print("you won")
	else:
		print("you lost")
		
