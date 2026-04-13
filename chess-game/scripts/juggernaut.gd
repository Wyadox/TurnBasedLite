extends Node

func JuggernautUpdate(board, piece):
	if piece.piece_type == Globals.PIECE_TYPES.JUGGERNAUT:
		piece.piece_type = Globals.PIECE_TYPES.JUGGERNAUT2
		piece.update_sprite()
		print(piece.piece_type)
	elif piece.piece_type == Globals.PIECE_TYPES.JUGGERNAUT2:
		piece.piece_type = Globals.PIECE_TYPES.JUGGERNAUT1
		piece.update_sprite()
		print(piece.piece_type)
