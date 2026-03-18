extends Node2D

@onready var board: Node2D = $Board


var piece_eval = {Globals.PIECE_TYPES.PAWN : 1, Globals.PIECE_TYPES.MITOSIS_PAWN : 1.25, Globals.PIECE_TYPES.WORM : 1.5, 
				Globals.PIECE_TYPES.CHECKER : 1.5, Globals.PIECE_TYPES.INFECTOR : 2, Globals.PIECE_TYPES.DUPLICATOR : 2, 
				Globals.PIECE_TYPES.HORSE_ARCHER : 3, Globals.PIECE_TYPES.STUN_KNIGHT : 3.75, Globals.PIECE_TYPES.TROJAN_HORSE : 3.5, 
				Globals.PIECE_TYPES.MAGMA_KNIGHT : 3.75, Globals.PIECE_TYPES.WARHORSE : 4, Globals.PIECE_TYPES.EXPLODING_BISHOP : 4, 
				Globals.PIECE_TYPES.ACROBISHOP : 3.5, Globals.PIECE_TYPES.ARCHBISHOP : 4, Globals.PIECE_TYPES.JOUST_BISHOP : 3.5, 
				Globals.PIECE_TYPES.SUMO : 5.5, Globals.PIECE_TYPES.WIZARD : 5.5, Globals.PIECE_TYPES.SHIELD_KING : 5, 
				Globals.PIECE_TYPES.JUGGERNAUT : 3, Globals.PIECE_TYPES.DUCK : 1, Globals.PIECE_TYPES.GUARDIAN_ANGEL : 3}

func board_evaluation(pieces : Array) -> int:
	var white_eval : int = 0
	var black_eval : int = 0
	
	var multiplier : float = 1.0
	
	for piece in pieces:
		if piece:
			if piece.stun_counter > 0:
					multiplier *= 0.75
			if piece.promoted:
					multiplier *= 1.25
			if piece.color == Globals.COLORS.WHITE:
				white_eval += piece_eval[piece.piece_type] * multiplier
			else:
				black_eval -= piece_eval[piece.piece_type] * multiplier
			#evaluation += piece_eval[piece.piece_type] * 1 if piece.color == Globals.COLORS.WHITE else -1
	print("White Eval: ", white_eval)
	print("Black Eval: ", black_eval)
	return white_eval + black_eval

# Other considerations
	# Piece position on board
	# Piece is stunned/infected/promoted/protected
	# Piece is low on health
	# Piece threat level while avoiding threat itself
