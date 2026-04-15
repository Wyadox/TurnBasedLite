extends Node

func Purify(dest_piece):
	if dest_piece.stun_counter > 0:
		dest_piece.stun_counter = 0
	if dest_piece.infect_counter > 0:
		dest_piece.infect_counter = 0
