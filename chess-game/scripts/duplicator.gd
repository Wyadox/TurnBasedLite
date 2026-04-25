extends Node

func Duplicate(selected_piece, dest_piece, board):
	selected_piece.piece_type = dest_piece.piece_type
	selected_piece.trojan_cloak_type = dest_piece.trojan_cloak_type
	selected_piece.update_sprite()
	if dest_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
		board.shield_king.append(selected_piece)
