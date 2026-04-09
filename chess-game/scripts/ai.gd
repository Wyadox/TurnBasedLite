extends Node2D

const POSITION_EVAL_INCREMENT : float = 0.05
const THREAT_EVAL_INCREMENT : float = 0.25

var piece_eval = {Globals.PIECE_TYPES.PAWN : 1, Globals.PIECE_TYPES.MITOSIS_PAWN : 1.25, Globals.PIECE_TYPES.WORM : 1.5, 
				Globals.PIECE_TYPES.CHECKER : 1.5, Globals.PIECE_TYPES.INFECTOR : 2, Globals.PIECE_TYPES.DUPLICATOR : 2, 
				Globals.PIECE_TYPES.HORSE_ARCHER : 3, Globals.PIECE_TYPES.STUN_KNIGHT : 3.75, Globals.PIECE_TYPES.TROJAN_HORSE : 3.5, 
				Globals.PIECE_TYPES.MAGMA_KNIGHT : 3.75, Globals.PIECE_TYPES.WARHORSE : 4, Globals.PIECE_TYPES.EXPLODING_BISHOP : 4, 
				Globals.PIECE_TYPES.ACROBISHOP : 3.5, Globals.PIECE_TYPES.ARCHBISHOP : 4, Globals.PIECE_TYPES.JOUST_BISHOP : 3.5, 
				Globals.PIECE_TYPES.SUMO : 5.5, Globals.PIECE_TYPES.WIZARD : 5.5, Globals.PIECE_TYPES.SHIELD_KING : 5, 
				Globals.PIECE_TYPES.JUGGERNAUT : 3, Globals.PIECE_TYPES.DUCK : 1, Globals.PIECE_TYPES.GUARDIAN_ANGEL : 3,
				Globals.PIECE_TYPES.JUGGERNAUT1 : 3, Globals.PIECE_TYPES.JUGGERNAUT2 : 3}

func board_evaluation(pieces : Array, noise : float) -> float:
	var white_eval : float = 0.0
	var black_eval : float = 0.0
	
	var multiplier : float
	
	var threat_map = {}
	for piece in pieces:
		for pos in piece.get_threatened_positions():
			if not threat_map.has(pos):
				threat_map[pos] = []
			threat_map[pos].append(piece)
	
	for piece in pieces:
		if piece:
			# Reset multiplier DUH
			multiplier = 1.0
			
			# Status Multipliers 
			if piece.stun_counter > 0:
					multiplier *= 0.9
			if piece.promoted:
					multiplier *= 1.05
			if piece.current_health != null:
				multiplier *= 1.0 + (0.2 * (piece.current_health / piece.MAX_HEALTH as float))
				
			var eval_adjustment : float = eval_positionAdjustment(piece) + eval_assessThreat(threat_map, piece)
			
			# Increment based on color of piece
			if piece.color == Globals.COLORS.WHITE:
				white_eval += (piece_eval[piece.piece_type] * multiplier) + eval_adjustment
			elif piece.color == Globals.COLORS.BLACK:
				black_eval -= (piece_eval[piece.piece_type] * multiplier) + eval_adjustment
	var result = white_eval + black_eval
	return result + randf_range(-noise, noise)

# Other considerations
	# Piece position on board
	# Piece is stunned/infected/promoted/protected
	# Piece is low on health
	# Piece threat level while avoiding threat itself
	
func eval_assessThreat(threat_map : Dictionary, eval_piece) -> float:
	var danger_count : int = 0
	var threateners = threat_map.get(eval_piece.board_position, [])
	for attacker in threateners:
		if attacker.color != eval_piece.color:
			danger_count += 1
			
	var threat_positions = threat_map.values().reduce(func(acc, attackers): return acc + attackers.filter(func(p): return p == eval_piece).size(), 0)
	
	return threat_positions * THREAT_EVAL_INCREMENT - danger_count * THREAT_EVAL_INCREMENT * 2.0

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

const GAME_SCENE = preload("res://scenes/game.tscn")
const PIECE_SCENE = preload("res://scenes/Piece.tscn")
const PIECE_SCRIPT = preload("res://scripts/piece.gd")
const BOARD_SCENE = preload("res://scenes/board.tscn")

var game_scene
var board

func start_minimax(pieces : Array, white_to_play : bool, difficulty_dict : Dictionary) -> Dictionary:
	game_scene = GAME_SCENE.instantiate()
	game_scene.real_game = false
	
	board = BOARD_SCENE.instantiate()
	board.real_board = false
	
	var new_pieces = []
	for piece in pieces:
		var copy : Piece = PIECE_SCENE.instantiate()
		copy.init_piece(piece.piece_type, piece.color, piece.board_position, board)
		copy.stun_counter = piece.stun_counter
		copy.promoted = piece.promoted
		copy.moved = piece.moved
		copy.current_health = piece.current_health
		new_pieces.append(copy)
	
	game_scene.board = board
	
	var start = Time.get_ticks_msec()
	var result = minimax(new_pieces, difficulty_dict["depth"], -INF, INF, white_to_play, difficulty_dict["noise"], difficulty_dict["slice_num"])
	print("Minimax took: ", Time.get_ticks_msec() - start, "ms")
	return result

func minimax(pieces : Array, depth : int, alpha : float, beta : float, maximizingPlayer : bool, noise : float, slice_num : int) -> Dictionary:
	var maximum_eval : float
	var minimum_eval : float
	var new_eval
	var best_move
	var best_piece
	
	if depth == 0:
		return {"ref" : null, "pos" : null, "eval" : board_evaluation(pieces, noise)}
		
	board.pieces = pieces
		
	var snapshot = snapshot_board(pieces)
		
	#if maximizingPlayer:
		#maximum_eval = -INF
		#for piece in pieces.duplicate():
			#if piece and piece.color != Globals.COLORS.WHITE:
				#continue
			#for move in get_move_list(piece, slice_num):
				#simulate_move(pieces, piece, move["pos"])
				#
				#new_eval = minimax(pieces, depth - 1, alpha, beta, false, noise, slice_num)
				#if new_eval["eval"] > maximum_eval:
					#maximum_eval = new_eval["eval"]
					#best_piece = piece
					#best_move = move["pos"]
				#alpha = max(alpha, new_eval["eval"])
				#
				#restore_board(snapshot, pieces)
				#
				#if beta <= alpha:
					#break
		#return {"ref" : best_piece, "pos" : best_move, "eval" : maximum_eval}
	if maximizingPlayer:
		maximum_eval = -INF
		var all_moves = []
		for piece in pieces.duplicate():
			if piece and piece.color != Globals.COLORS.WHITE:
				continue
			for move in get_move_list(piece, slice_num):
				all_moves.append({"piece": piece, "move": move})
		
		# Set a default from the first available move so best_piece is never null
		if all_moves.size() > 0:
			best_piece = all_moves[0]["piece"]
			best_move = all_moves[0]["move"]["pos"]
			
		for entry in all_moves:
			var piece = entry["piece"]
			var move = entry["move"]
			simulate_move(pieces, piece, move["pos"])
			new_eval = minimax(pieces, depth - 1, alpha, beta, false, noise, slice_num)
			if new_eval["eval"] > maximum_eval:
				maximum_eval = new_eval["eval"]
				best_piece = piece
				best_move = move["pos"]
			alpha = max(alpha, new_eval["eval"])
			restore_board(snapshot, pieces)
			if beta <= alpha:
				break
		return {"ref": best_piece, "pos": best_move, "eval": maximum_eval}
	#else:
		#minimum_eval = INF
		#for piece in pieces.duplicate():
			#if piece and piece.color != Globals.COLORS.BLACK:
				#continue
			#for move in get_move_list(piece, slice_num):
				#simulate_move(pieces, piece, move["pos"])
				#
				#new_eval = minimax(pieces, depth - 1, alpha, beta, true, noise, slice_num)
				#if new_eval["eval"] < minimum_eval:
					#minimum_eval = new_eval["eval"]
					#best_piece = piece
					#best_move = move["pos"]
				#beta = min(beta, new_eval["eval"])
				#
				#restore_board(snapshot, pieces)
				#
				#if beta <= alpha:
					#break
		#return {"ref" : best_piece, "pos" : best_move, "eval" : minimum_eval}
	else:
		minimum_eval = INF
		var all_moves = []
		for piece in pieces.duplicate():
			if piece and piece.color != Globals.COLORS.BLACK:
				continue
			for move in get_move_list(piece, slice_num):
				all_moves.append({"piece": piece, "move": move})
		
		# Set a default from the first available move so best_piece is never null
		if all_moves.size() > 0:
			best_piece = all_moves[0]["piece"]
			best_move = all_moves[0]["move"]["pos"]
			
		for entry in all_moves:
			var piece = entry["piece"]
			var move = entry["move"]
			simulate_move(pieces, piece, move["pos"])
			new_eval = minimax(pieces, depth - 1, alpha, beta, true, noise, slice_num)
			if new_eval["eval"] < minimum_eval:
				minimum_eval = new_eval["eval"]
				best_piece = piece
				best_move = move["pos"]
			alpha = max(alpha, new_eval["eval"])
			restore_board(snapshot, pieces)
			if beta <= alpha:
				break
		return {"ref": best_piece, "pos": best_move, "eval": minimum_eval}

func get_move_list(piece : Piece, slice_num : int):
	var moves = []
	
	if piece.color == Globals.COLORS.TILE:
		return moves
	
	var positions = piece.get_moveable_positions() + piece.get_threatened_positions()
	
	for pos in positions:
		var score : int = 0
		
		var dest_piece : Piece = piece.board_handle.get_piece(pos)
		
		# REVISIT FOR GUARDIAN ANGEL and SUMO ROOK
		if dest_piece != null and ((dest_piece.color == Globals.COLORS.TILE and dest_piece.piece_type != Globals.PIECE_TYPES.WEB) or (dest_piece.color == piece.color)):
			print("move disregarded")
			continue
		
		if dest_piece != null and dest_piece.color != Globals.COLORS.TILE and dest_piece.color != piece.color:
			score += piece_eval[dest_piece.piece_type] - piece_eval[piece.piece_type]
		
		moves.append({
			"pos": pos,
			"score": score
		})
		
	moves.sort_custom(func(a, b): return a.score > b.score)
	moves = moves.slice(0, slice_num)
	
	return moves

func snapshot_board(pieces : Array):
	var snap = []
	for piece in pieces:
		snap.append({
			"ref": piece,
			"board_position": piece.board_position,
			"promoted": piece.promoted,
			"moved": piece.moved,
			"stun_counter": piece.stun_counter,
			"current_health": piece.current_health,
			"alive": true
		})
	return snap

func restore_board(snapshot : Array, pieces : Array):
	for it in snapshot:
		var piece = it["ref"]
		piece.board_position = it["board_position"]
		piece.promoted = it["promoted"]
		piece.moved = it["moved"]
		piece.stun_counter = it["stun_counter"]
		piece.current_health = it["current_health"]
		if not piece in pieces:
			pieces.append(piece)
			
	pieces.clear()
	for it in snapshot:
		pieces.append(it["ref"])
		
	board.pieces = pieces

func simulate_move(pieces, piece, pos):
	board.pieces = pieces
	game_scene.board = board
	game_scene.board.pieces = pieces
	
	game_scene.selected_piece = piece
	game_scene.previous_position = piece.board_position
	game_scene.drop_piece(false, pos)

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
