extends Node

func WarhorseCapture(board, warhorse):
	for pos in warhorse.warhorse_capture_pos():
		var piece = board.get_piece(pos)
		print(piece)
		if piece != null:
			board.on_capture(piece, warhorse, board)
	warhorse.stun_counter = 3
