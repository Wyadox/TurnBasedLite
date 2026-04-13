extends Node2D

func trojan_spawn(dest_piece, board):
	for position in dest_piece.get_trojan_spawn_positions():
		if board.get_piece(position) == null:
			board.create_piece(
				Globals.PIECE_TYPES.PAWN,
				dest_piece.color,
				position
			)
			var spawned_pawn = board.get_piece(position)
			spawned_pawn.starting_rank = dest_piece.starting_rank
			SignalBus.emit_signal("trojan_spawned", position)
