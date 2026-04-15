extends Node

func SpawnMagma(previous_position, board):
	board.create_piece(Globals.PIECE_TYPES.MAGMA_HIGH, Globals.COLORS.TILE, previous_position)
	var magma = board.get_piece(previous_position)
	magma.scale *= 1.25
	magma.cool_counter = 6
