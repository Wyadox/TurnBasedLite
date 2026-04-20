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
			if new_piece.starting_rank < 3 and (new_piece.board_position[1] == 6 or new_piece.board_position[1] > dest_piece.board_position[1]):
				new_piece.promoted = true
			elif new_piece.starting_rank > 4 and (new_piece.board_position[1] == 0 or new_piece.board_position[1] < dest_piece.board_position[1]):
				new_piece.promoted = true
			SignalBus.emit_signal("trojan_spawned", position)
