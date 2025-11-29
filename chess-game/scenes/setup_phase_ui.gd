extends Control
signal spawn_piece(piece_type)

func _on_button_pressed() -> void:
	print("Pawn")
	emit_signal("spawn_piece", Globals.PIECE_TYPES.PAWN)
