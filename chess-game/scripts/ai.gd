extends Node2D

const POSITION_EVAL_INCREMENT : float = 0.05
const THREAT_EVAL_INCREMENT : float = 0.15
const HEALTH_EVAL_INCREMENT : float = 0.25
const MOBILITY_EVAL_INCREMENT : float = 0.02

const STUN_MULTIPLIER : float = 0.5
const PROMOTED_MULTIPLIER : float = 1.25
const INFECT_MULTIPLIER : float = 0.3
const DANGER_MULTIPLIER : float = 2.5
const THREATEN_MULTIPLIER : float = 1.5
const CAPTURING_PIECE_MULTIPLIER : float = 0.1

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
				multiplier *= STUN_MULTIPLIER
			if piece.infect_counter > 0:
				multiplier *= INFECT_MULTIPLIER
			if piece.promoted:
				multiplier *= PROMOTED_MULTIPLIER
			if piece.current_health != null:
				multiplier *= 1.0 + (HEALTH_EVAL_INCREMENT * (piece.current_health / piece.MAX_HEALTH as float))
				
			var positional : float = eval_positionAdjustment(piece) 
			var threat : float = eval_assessThreat(threat_map, piece, pieces)
			var mobility : float = eval_mobility(piece)
			
			var eval_sum : float = positional + threat + mobility
			
			# Increment based on color of piece
			if piece.color == Globals.COLORS.WHITE:
				white_eval += (piece_eval[piece.piece_type] * multiplier) + eval_sum
			elif piece.color == Globals.COLORS.BLACK:
				black_eval -= (piece_eval[piece.piece_type] * multiplier) + eval_sum
	var result = white_eval + black_eval
	return result + randf_range(-noise, noise)

# Other considerations
	# Piece position on board
	# Piece is stunned/infected/promoted/protected
	# Piece is low on health
	# Piece threat level while avoiding threat itself
	
func eval_assessThreat(threat_map : Dictionary, eval_piece, pieces) -> float:
	var danger_count : int = 0
	var threateners = threat_map.get(eval_piece.board_position, [])
	for attacker in threateners:
		if attacker.color != eval_piece.color:
			danger_count += 1
	
	var threat_count : int = 0
	for pos in eval_piece.get_threatened_positions():
		var dest_piece
		for piece in pieces:
			if piece.board_position == pos:
				dest_piece = piece
				break
		if dest_piece != null and dest_piece.color != eval_piece.color and dest_piece.color != Globals.COLORS.TILE:
			threat_count += piece_eval.get(dest_piece.piece_type, 1)
		else:
			threat_count += 1
	
	var score = threat_count * THREAT_EVAL_INCREMENT * THREATEN_MULTIPLIER - danger_count * THREAT_EVAL_INCREMENT * DANGER_MULTIPLIER
	
	return score

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

func eval_mobility(piece) -> float:
	return piece.get_moveable_positions().size() * MOBILITY_EVAL_INCREMENT

const GAME_SCENE = preload("res://scenes/game.tscn")
const PIECE_SCENE = preload("res://scenes/Piece.tscn")
const PIECE_SCRIPT = preload("res://scripts/piece.gd")
const BOARD_SCENE = preload("res://scenes/board.tscn")

const MOVE_INDEX_CUTOFF : int = 3
const DEPTH_CUTOFF : int = 2

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
		copy.starting_rank = piece.starting_rank
		new_pieces.append(copy)
	
	game_scene.board = board
	
	board.register_king()
	
	var best_result = {}
	var time_limit = difficulty_dict.get("time_limit", 2000)
	var start = Time.get_ticks_msec()
	var previous_best = null
	var previous_score = 0.0
	var prune_window = 2.0
	
	for level in range(1, difficulty_dict["depth"] + 1):
		var alpha = previous_score - prune_window
		var beta = previous_score + prune_window
		
		var result = minimax(new_pieces, level, alpha, beta, white_to_play, difficulty_dict["noise"], difficulty_dict["slice_num"], previous_best)
		
		if result["eval"] <= alpha or result["eval"] >= beta:
			result = minimax(new_pieces, level, -INF, INF, white_to_play, difficulty_dict["noise"], difficulty_dict["slice_num"], previous_best)
			
		previous_score = result["eval"]
		previous_best = {"ref": result["ref"], "pos": result["pos"]}
		
		if Time.get_ticks_msec() - start > time_limit:
			break
		best_result = result
		previous_best = {"ref" : result["ref"], "pos" : result["pos"]}
	
	for piece in new_pieces:
		piece.queue_free()
	board.queue_free()
	game_scene.queue_free()
	
	return best_result

func minimax(pieces : Array, depth : int, alpha : float, beta : float, maximizingPlayer : bool, noise : float, slice_num : int, previous_best) -> Dictionary:
	var maximum_eval : float
	var minimum_eval : float
	var new_eval
	var best_move
	var best_piece
	
	if depth == 0:
		return {"ref" : null, "pos" : null, "eval" : board_evaluation(pieces, noise)}
		
	board.pieces = pieces
		
	var snapshot = snapshot_board(pieces)
		
	if maximizingPlayer:
		maximum_eval = -INF
		var move_index = 0
		for piece in pieces.duplicate():
			if piece and piece.color != Globals.COLORS.WHITE or piece.stun_counter > 0:
				continue
			for move in get_move_list(piece, slice_num, previous_best):
				simulate_move(pieces, piece, move["pos"])
				
				var search_depth = depth - 1
				if move_index >= MOVE_INDEX_CUTOFF and depth >= DEPTH_CUTOFF and not is_capture(move):
					search_depth = max(0, depth - 2)
				
				new_eval = minimax(pieces, search_depth, alpha, beta, false, noise, slice_num, previous_best)
				if new_eval["eval"] > maximum_eval:
					maximum_eval = new_eval["eval"]
					best_piece = piece
					best_move = move["pos"]
				alpha = max(alpha, new_eval["eval"])
				
				if search_depth < depth - 1 and new_eval["eval"] > alpha:
					new_eval = minimax(pieces, depth - 1, alpha, beta, false, noise, slice_num, previous_best)
				
				restore_board(snapshot, pieces)
				
				move_index += 1
				
				if beta <= alpha:
					break
		return {"ref" : best_piece, "pos" : best_move, "eval" : maximum_eval}
	else:
		minimum_eval = INF
		var move_index = 0
		for piece in pieces.duplicate():
			if piece and piece.color != Globals.COLORS.BLACK or piece.stun_counter > 0:
				continue
			for move in get_move_list(piece, slice_num, previous_best):
				simulate_move(pieces, piece, move["pos"])
				
				var search_depth = depth - 1
				if move_index >= MOVE_INDEX_CUTOFF and depth >= DEPTH_CUTOFF and not is_capture(move):
					search_depth = max(0, depth - 2)
				
				new_eval = minimax(pieces, search_depth, alpha, beta, true, noise, slice_num, previous_best)
				if new_eval["eval"] < minimum_eval:
					minimum_eval = new_eval["eval"]
					best_piece = piece
					best_move = move["pos"]
				beta = min(beta, new_eval["eval"])
				
				if search_depth < depth - 1 and new_eval["eval"] > alpha:
					new_eval = minimax(pieces, depth - 1, alpha, beta, false, noise, slice_num, previous_best)
				
				restore_board(snapshot, pieces)
				
				if beta <= alpha:
					break
		return {"ref" : best_piece, "pos" : best_move, "eval" : minimum_eval}

func is_capture(move : Dictionary) -> bool:
	var dest_piece = board.get_piece(move["pos"])
	return dest_piece != null and dest_piece.color != Globals.COLORS.TILE

func get_move_list(piece : Piece, slice_num : int, previous_best):
	var moves = []
	
	if piece.color == Globals.COLORS.TILE:
		return moves
	
	var positions = piece.get_moveable_positions() + piece.get_threatened_positions()
	
	for pos in positions:
		var score : float = 0.0
		
		var dest_piece : Piece = piece.board_handle.get_piece(pos)
		
		# REVISIT FOR GUARDIAN ANGEL and SUMO ROOK
		if dest_piece != null and ((dest_piece.color == Globals.COLORS.TILE and dest_piece.piece_type != Globals.PIECE_TYPES.WEB) or (dest_piece.color == piece.color and dest_piece.piece_type != Globals.PIECE_TYPES.DUPLICATOR)):
			continue
		
		if !game_scene.valid_move(piece.board_position, pos):
			continue
		
		if dest_piece != null and dest_piece.color != Globals.COLORS.TILE and dest_piece.color != piece.color:
			score += piece_eval[dest_piece.piece_type] - (piece_eval[piece.piece_type] * CAPTURING_PIECE_MULTIPLIER)
		
		var old_pos = piece.board_position
		piece.board_position = pos
		score += eval_positionAdjustment(piece)
		piece.board_position = old_pos
		
		var threat_map = {}
		for threat_piece in board.pieces:
			if threat_piece == piece or threat_piece.color == piece.color:
				continue
			for threat_pos in threat_piece.get_threatened_positions():
				if not threat_map.has(threat_pos):
					threat_map[threat_pos] = []
				threat_map[threat_pos].append(threat_piece)
		
		var danger_count = threat_map.get(pos, []).size()
		score -= danger_count * THREAT_EVAL_INCREMENT * DANGER_MULTIPLIER
		
		moves.append({
			"pos": pos,
			"score": score
		})
		
	moves.sort_custom(func(a, b): return a.score > b.score)
	
	if previous_best != null and previous_best["ref"] == piece:
		for it in range(moves.size()):
			if moves[it]["pos"] == previous_best["pos"]:
					var best = moves[it]
					moves.remove_at(it)
					moves.push_front(best)
					break
	
	moves = moves.slice(0, slice_num)
	
	return moves

#
# HERE if you add piece attributes
#
func snapshot_board(pieces : Array):
	var snap = []
	for piece in pieces:
		snap.append({
			"ref" : piece,
			"board_position" : piece.board_position,
			"promoted" : piece.promoted,
			"moved" : piece.moved,
			"stun_counter" : piece.stun_counter,
			"current_health" : piece.current_health,
			"starting_rank" : piece.starting_rank,
			"color" : piece.color,
			"piece_type" : piece.piece_type,
			"alive": true
		})
	snap.append({
		"white_king_pos": board.white_king_pos,
		"black_king_pos": board.black_king_pos
	})
	return snap

func restore_board(snapshot : Array, pieces : Array):
	var board_state = snapshot[-1]
	var piece_snap = snapshot.slice(0, snapshot.size() -1)
	
	var snap_refs = []
	for it in piece_snap:
		snap_refs.append(it["ref"])
	
	for piece in pieces:
		if piece not in snap_refs:
			piece.queue_free()
	
	for it in piece_snap:
		var piece = it["ref"]
		piece.board_position = it["board_position"]
		piece.promoted = it["promoted"]
		piece.moved = it["moved"]
		piece.stun_counter = it["stun_counter"]
		piece.current_health = it["current_health"]
		piece.starting_rank = it["starting_rank"]
		piece.color = it["color"]
		piece.piece_type = it["piece_type"]
		if not piece in pieces:
			pieces.append(piece)
			
	pieces.clear()
	for it in piece_snap:
		pieces.append(it["ref"])
		
	board.pieces = pieces
	board.white_king_pos = board_state["white_king_pos"]
	board.black_king_pos = board_state["black_king_pos"]

func simulate_move(pieces, piece, pos) -> bool:
	board.pieces = pieces
	game_scene.board = board
	game_scene.board.pieces = pieces
	
	game_scene.selected_piece = piece
	game_scene.previous_position = piece.board_position
	return game_scene.drop_piece(false, pos)

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
