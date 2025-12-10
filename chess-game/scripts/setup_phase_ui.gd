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
	
func _on_board_refund_piece(piece_type: Variant) -> void:
	if (!valid_spawn(piece_type)):
		if (status == Globals.COLORS.WHITE):
			white_dict.erase(piece_type)
		else:
			black_dict.erase(piece_type)
	
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
		
static func determineAiPieces():
	var piecesToSpawn = []
	var pieces = [Globals.PIECE_TYPES.KNIGHT,
	Globals.PIECE_TYPES.BISHOP,
	Globals.PIECE_TYPES.KING,
	Globals.PIECE_TYPES.PAWN,
	Globals.PIECE_TYPES.HORSE_ARCHER,
	Globals.PIECE_TYPES.ARCHBISHOP,
	Globals.PIECE_TYPES.MITOSIS_PAWN,
	Globals.PIECE_TYPES.SHIELD_KING,
	Globals.PIECE_TYPES.DUCK,
	Globals.PIECE_TYPES.WORM,
	Globals.PIECE_TYPES.CHECKER,
	Globals.PIECE_TYPES.EXPLODING_BISHOP,
	Globals.PIECE_TYPES.ACROBISHOP,
	Globals.PIECE_TYPES.JOUST_BISHOP,
	Globals.PIECE_TYPES.STUN_KNIGHT,
	Globals.PIECE_TYPES.TROJAN_HORSE]
	
	var pos
	for i in 6:
		var roll = randi() % pieces.size()
		pos = Vector2(i, 0)
		piecesToSpawn.push_back(pieces[roll])
		piecesToSpawn.push_back(pos)
		pieces.remove_at(roll)
		print(pos)
		
	return piecesToSpawn
	


func _on_joust_button_pressed() -> void:
	print("Joust")
	if (valid_spawn(Globals.PIECE_TYPES.JOUST_BISHOP)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.JOUST_BISHOP)


func _on_arco_button_pressed() -> void:
	print("Arco")
	if (valid_spawn(Globals.PIECE_TYPES.ACROBISHOP)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.ACROBISHOP)


func _on_shield_button_pressed() -> void:
	print("Shield")
	if (valid_spawn(Globals.PIECE_TYPES.SHIELD_KING)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.SHIELD_KING)


func _on_duck_button_pressed() -> void:
	print("Duck")
	if (valid_spawn(Globals.PIECE_TYPES.DUCK)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.DUCK)


func _on_worm_button_pressed() -> void:
	print("Worm")
	if (valid_spawn(Globals.PIECE_TYPES.WORM)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.WORM)


func _on_checker_button_pressed() -> void:
	print("Checker")
	if (valid_spawn(Globals.PIECE_TYPES.CHECKER)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.CHECKER)


func _on_explode_button_pressed() -> void:
	print("Explode")
	if (valid_spawn(Globals.PIECE_TYPES.EXPLODING_BISHOP)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.EXPLODING_BISHOP)


func _on_stun_button_pressed() -> void:
	print("Stun")
	if (valid_spawn(Globals.PIECE_TYPES.STUN_KNIGHT)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.STUN_KNIGHT)


func _on_trojan_button_pressed() -> void:
	print("Trojan")
	if (valid_spawn(Globals.PIECE_TYPES.TROJAN_HORSE)):
		emit_signal("spawn_piece", Globals.PIECE_TYPES.TROJAN_HORSE)
