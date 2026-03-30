extends Node2D

#@onready var board: Node2D = $Board

const POSITION_EVAL_INCREMENT : float = 0.1
const THREAT_EVAL_INCREMENT : float = 0.25

var piece_eval = {Globals.PIECE_TYPES.PAWN : 1, Globals.PIECE_TYPES.MITOSIS_PAWN : 1.25, Globals.PIECE_TYPES.WORM : 1.5, 
				Globals.PIECE_TYPES.CHECKER : 1.5, Globals.PIECE_TYPES.INFECTOR : 2, Globals.PIECE_TYPES.DUPLICATOR : 2, 
				Globals.PIECE_TYPES.HORSE_ARCHER : 3, Globals.PIECE_TYPES.STUN_KNIGHT : 3.75, Globals.PIECE_TYPES.TROJAN_HORSE : 3.5, 
				Globals.PIECE_TYPES.MAGMA_KNIGHT : 3.75, Globals.PIECE_TYPES.WARHORSE : 4, Globals.PIECE_TYPES.EXPLODING_BISHOP : 4, 
				Globals.PIECE_TYPES.ACROBISHOP : 3.5, Globals.PIECE_TYPES.ARCHBISHOP : 4, Globals.PIECE_TYPES.JOUST_BISHOP : 3.5, 
				Globals.PIECE_TYPES.SUMO : 5.5, Globals.PIECE_TYPES.WIZARD : 5.5, Globals.PIECE_TYPES.SHIELD_KING : 5, 
				Globals.PIECE_TYPES.JUGGERNAUT : 3, Globals.PIECE_TYPES.DUCK : 1, Globals.PIECE_TYPES.GUARDIAN_ANGEL : 3}

func board_evaluation(pieces : Array) -> float:
	var white_eval : float = 0
	var black_eval : float = 0
	
	var multiplier : float
	
	for piece in pieces:
		if piece:
			# Reset multiplier DUH
			multiplier = 1.0
			
			# Status Multipliers 
			if piece.stun_counter > 0:
					multiplier *= 0.75
			if piece.promoted:
					multiplier *= 1.25
			if piece.current_health != null:
				multiplier *= 1.0 + (0.5 * (piece.current_health / piece.MAX_HEALTH as float))
				
			var eval_adjustment : float = eval_positionAdjustment(piece) + eval_assessThreat(pieces, piece)
			
			# Increment based on color of piece
			if piece.color == Globals.COLORS.WHITE:
				white_eval += (piece_eval[piece.piece_type] * multiplier) + eval_adjustment
			else:
				black_eval -= (piece_eval[piece.piece_type] * multiplier) + eval_adjustment
			#evaluation += piece_eval[piece.piece_type] * 1 if piece.color == Globals.COLORS.WHITE else -1
	
	print("White Eval: ", white_eval)
	print("Black Eval: ", black_eval)
	return white_eval + black_eval

# Other considerations
	# Piece position on board
	# Piece is stunned/infected/promoted/protected
	# Piece is low on health
	# Piece threat level while avoiding threat itself
	
func eval_assessThreat(pieces, eval_piece) -> float:
	var danger_count : int = 0
	for piece in pieces:
		for pos in piece.get_threatened_positions():
			if eval_piece.board_position == pos and piece != eval_piece and piece.color != eval_piece.color:
				danger_count += 1
	
	return eval_threatLevel(eval_piece) - danger_count * THREAT_EVAL_INCREMENT

# Threatening more pieces = better evaluation
func eval_threatLevel(piece) -> float:
	return piece.get_threatened_positions().size() * THREAT_EVAL_INCREMENT

#
# If "corner" is true, then don't flip the values
# If "corner" is false, then flip the values
#
# This method was designed for corner preference but center preference is literally the opposite so I combined them
#
func eval_cornerOrCenterPref(piece, corner : bool = true) -> float:
	var x_multiplier = abs(piece.board_position.x - 3)
	var y_multiplier = abs(piece.board_position.y - 3)
	
	var overall_multiplier = x_multiplier + y_multiplier - 3
	
	var flip : float
	if corner:
		flip = 1.0
	else:
		flip = -1.0
	
	return overall_multiplier * POSITION_EVAL_INCREMENT * flip
	
func eval_positionAdjustment(piece) -> float:
	match piece.piece_type:
		Globals.PIECE_TYPES.PAWN:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.KNIGHT:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.BISHOP:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.KING:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.HORSE_ARCHER:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.ARCHBISHOP:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.MITOSIS_PAWN:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.SHIELD_KING:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.DUCK:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.WORM:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.CHECKER:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.EXPLODING_BISHOP:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.ACROBISHOP:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.JOUST_BISHOP:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.STUN_KNIGHT:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.TROJAN_HORSE:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.GUARDIAN_ANGEL:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.SUMO:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.MAGMA_KNIGHT:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.DUPLICATOR:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.WARHORSE:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.INFECTOR:
			return eval_cornerOrCenterPref(piece, false)
		Globals.PIECE_TYPES.JUGGERNAUT:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.JUGGERNAUT2:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.JUGGERNAUT1:
			return eval_cornerOrCenterPref(piece)
		Globals.PIECE_TYPES.WIZARD:
			return eval_cornerOrCenterPref(piece)
	return 0
	
const GAME_SCENE = preload("res://scenes/game.tscn")
const PIECE_SCENE = preload("res://scenes/Piece.tscn")
const PIECE_SCRIPT = preload("res://scripts/piece.gd")
const BOARD_SCENE = preload("res://scenes/board.tscn")

func minimax(pieces, depth : int, alpha : int, beta : int, maximizingPlayer : bool) -> float:
	var maximum_eval : float
	var minimum_eval : float
	var new_eval
	
	#var game_scene = GAME_SCENE.instantiate()
	#game_scene.board.pieces = pieces
	var new_pieces = []
	var new_piece : Piece
	var new_board
	
	var game_scene = GAME_SCENE.instantiate()
	var board = BOARD_SCENE.instantiate()
	board.pieces = pieces
	game_scene.board = board
	
	if depth == 0:
		var result = board_evaluation(pieces)
		print("minimax final result: ", result)
		return result
		
	#for pos in piece.get_moveable_positions() + piece.get_threatened_positions():
		
	if maximizingPlayer:
		maximum_eval = -INF
		for piece in pieces:
			var moves = get_move_list(piece)
			print("MAX MOVE SIZE: ", moves.size())
			for move in moves:
				var pos = move.pos
				if !game_scene.valid_move(piece.board_position, pos):
					print("NOT VALID BREAK")
					break
				
				new_pieces = []
				
				new_board = BOARD_SCENE.instantiate()
				
				new_piece = PIECE_SCENE.instantiate()
				new_piece.init_piece(piece.piece_type, piece.color, piece.board_position, new_board)
				new_piece.promoted = piece.promoted
				new_piece.moved = piece.moved
				new_piece.stun_counter = piece.stun_counter
				
				if new_piece == null:
					push_error("Duplicate FAILED")
					continue
				
				if not new_piece is Piece:
					push_error("Not a Piece: ", str(new_piece))
					continue
				
				print("BOARD HERE: ", new_board)
				new_piece.move_position(pos)
				new_pieces.append(new_piece)
				for it in pieces:
					if it != piece:
						new_piece = PIECE_SCENE.instantiate()
						new_piece.init_piece(it.piece_type, it.color, it.board_position, new_board)
						new_piece.promoted = it.promoted
						new_piece.moved = it.moved
						new_piece.stun_counter = it.stun_counter
						new_pieces.append(new_piece)
				new_board.pieces = new_pieces
				new_eval = minimax(new_pieces, depth - 1, alpha, beta, false)
				maximum_eval = max(maximum_eval, new_eval)
				alpha = max(alpha, new_eval)
				if beta <= alpha:
					print("max BREAK")
					break
		return maximum_eval
	else:
		minimum_eval = INF
		for piece in pieces:
			var moves = get_move_list(piece)
			print("MIN MOVE SIZE: ", moves.size())
			for move in moves:
				var pos = move.pos
				if !game_scene.valid_move(piece.board_position, pos):
					print("NOT VALID BREAK")
					break
				
				new_pieces = []
				
				new_board = BOARD_SCENE.instantiate()
				
				new_piece = PIECE_SCENE.instantiate()
				new_piece.init_piece(piece.piece_type, piece.color, piece.board_position, new_board)
				new_piece.promoted = piece.promoted
				new_piece.moved = piece.moved
				new_piece.stun_counter = piece.stun_counter
				
				if new_piece == null:
					push_error("Duplicate FAILED")
					continue
				
				if not new_piece is Piece:
					push_error("Not a Piece: ", str(new_piece))
					continue
				
				new_piece.move_position(pos)
				new_pieces.append(new_piece)
				for it in pieces:
					if it != piece:
						new_piece = PIECE_SCENE.instantiate()
						new_piece.init_piece(it.piece_type, it.color, it.board_position, new_board)
						new_piece.promoted = it.promoted
						new_piece.moved = it.moved
						new_piece.stun_counter = it.stun_counter
						new_pieces.append(new_piece)
				new_board.pieces = new_pieces
				new_eval = minimax(new_pieces, depth - 1, alpha, beta, true)
				minimum_eval = min(minimum_eval, new_eval)
				beta = max(beta, new_eval)
				if beta <= alpha:
					print("min BREAK")
					break
		return minimum_eval

func get_move_list(piece : Piece):
	var moves = []
	
	var positions = piece.get_moveable_positions() + piece.get_threatened_positions()
	
	for pos in positions:
		var score : int = 0
		
		var dest_piece : Piece = piece.board_handle.get_piece(pos)
		
		if dest_piece != null:
			score += piece_eval[dest_piece.piece_type] - piece_eval[piece.piece_type]
		
		moves.append({
			"pos": pos,
			"score": score
		})
		
	moves.sort_custom(func(a, b): return a.score > b.score)
	moves = moves.slice(0, 8)
	
	return moves
