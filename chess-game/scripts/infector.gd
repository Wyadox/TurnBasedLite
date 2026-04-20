extends Node

func InfectPiece(dest_piece, selected_piece):
	dest_piece.stun_counter = 2
	dest_piece.infect_counter = 2
	dest_piece.starting_rank = selected_piece.starting_rank
