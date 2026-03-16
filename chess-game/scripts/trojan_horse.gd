extends Node2D

func trojan_spawn(dest_piece, board):
	for position in dest_piece.get_trojan_spawn_positions():
		if board.get_piece(position) == null:
			board.create_piece(
				Globals.PIECE_TYPES.PAWN,
				dest_piece.color,
				position
			)
