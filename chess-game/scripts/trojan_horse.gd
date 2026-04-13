extends Node2D

func trojan_spawn(dest_piece : Piece, board):
	for position in dest_piece.get_trojan_spawn_positions():
		if board.get_piece(position) == null:
			var new_piece : Piece = board.create_piece(
				Globals.PIECE_TYPES.PAWN,
				dest_piece.color,
				position
			)
			new_piece.starting_rank = dest_piece.starting_rank
			SignalBus.emit_signal("trojan_spawned", position)
