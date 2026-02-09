extends Node2D

#@onready var board = $Board
var explosionScene = preload("res://scenes/Explosion.tscn")

func explode_range(dest_piece, selected_piece, board):
	if dest_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
		spawn_explosion(dest_piece.position)
		board.delete_piece(dest_piece)
		board.delete_piece(selected_piece)
		return
	for position in dest_piece.bishop_explode_positions():
		var piece_around = board.get_piece(position)
		if piece_around != null && piece_around.piece_type == Globals.PIECE_TYPES.SHIELD_KING && selected_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
			spawn_explosion(position)
			board.delete_piece(piece_around)
			board.delete_piece(selected_piece)
			return true
			# When we have multiple shield kings on board, will need to fix this.
	for position in dest_piece.bishop_explode_positions():
		var piece_around = board.get_piece(position)
		if piece_around != null && piece_around.piece_type != Globals.PIECE_TYPES.DUCK && board.piece_is_protected(piece_around) == false:
			spawn_explosion(position)
			board.delete_piece(piece_around)
		if selected_piece.piece_type != Globals.PIECE_TYPES.HORSE_ARCHER:
				board.delete_piece(selected_piece)
		return false

func spawn_explosion(pos : Vector2):
	var actual_pos = Vector2(pos.x * 120 + 60, pos.y * 120 + 60)
	var explosion = explosionScene.instantiate()
	explosion.position = actual_pos
	add_child(explosion)
