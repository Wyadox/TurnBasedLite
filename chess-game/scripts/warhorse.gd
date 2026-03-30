extends Node

const WARHORSE_CAPTURE_INCREMENTS = [[0, 1], [1, 0], [0, -1], [-1, 0]]

func WarhorseCapture(board, warhorse, dest_piece):
	for inc in WARHORSE_CAPTURE_INCREMENTS:
		var pos = Vector2(dest_piece.board_position[0]+inc[0], dest_piece.board_position[1]+inc[1])
		print(pos)
		var piece = board.get_piece(pos)
		if piece != null:
			board.on_capture(piece, warhorse, board)
	warhorse.stun_counter = 3
