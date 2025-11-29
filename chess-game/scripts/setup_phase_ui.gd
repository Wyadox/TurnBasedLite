extends Control
signal spawn_piece(piece_type)

var status = Globals.COLORS.WHITE
var white_dict = {}
var black_dict = {}

func valid_spawn(piece_type : Globals.PIECE_TYPES) -> bool:
	if (status == Globals.COLORS.WHITE and !white_dict.has(piece_type)) or (status == Globals.COLORS.BLACK and !black_dict.has(piece_type)):
		if (status == Globals.COLORS.WHITE):
			white_dict[piece_type] = true
		else:
			black_dict[piece_type] = true
		return true
	return false
	
func _on_board_set_status(color: Variant) -> void:
	status = color

func _on_pawn_button_pressed() -> void:
	print("Pawn")
	if (valid_spawn(Globals.PIECE_TYPES.PAWN)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.PAWN)

func _on_bishop_button_pressed() -> void:
	print("Bishop")
	if (valid_spawn(Globals.PIECE_TYPES.BISHOP)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.BISHOP)

func _on_knight_button_pressed() -> void:
	print("Knight")
	if (valid_spawn(Globals.PIECE_TYPES.KNIGHT)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.KNIGHT)

func _on_king_button_pressed() -> void:
	print("King")
	if (valid_spawn(Globals.PIECE_TYPES.KING)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.KING)

func _on_archer_button_pressed() -> void:
	print("Archer")
	if (valid_spawn(Globals.PIECE_TYPES.HORSE_ARCHER)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.HORSE_ARCHER)

func _on_archbishop_button_pressed() -> void:
	print("Archbishop")
	if (valid_spawn(Globals.PIECE_TYPES.ARCHBISHOP)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.ARCHBISHOP)


func _on_mitosis_button_pressed() -> void:
	print("Mitosis")
	if (valid_spawn(Globals.PIECE_TYPES.MITOSIS_PAWN)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.MITOSIS_PAWN)
