extends Control
signal spawn_piece(piece_type)

func _on_pawn_button_pressed() -> void:
	print("Pawn")
	emit_signal("spawn_piece", Globals.PIECE_TYPES.PAWN)


func _on_bishop_button_pressed() -> void:
	print("Bishop")
	emit_signal("spawn_piece", Globals.PIECE_TYPES.BISHOP)


func _on_knight_button_pressed() -> void:
	print("Kinght")
	emit_signal("spawn_piece", Globals.PIECE_TYPES.KNIGHT)


func _on_king_button_pressed() -> void:
	print("King")
	emit_signal("spawn_piece", Globals.PIECE_TYPES.KING)
