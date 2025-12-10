extends Node2D

@onready var sprite = $Sprite2D

const SPRITE_SIZE = 32
const CELL_SIZE = 120

const X_OFFSET = 60
const Y_OFFSET = 60

@export var piece_type: Globals.PIECE_TYPES
@export var color: Globals.COLORS
@export var board_position: Vector2

var board_handle;

@export var moved: bool;
@export var promoted: bool;
@export var stun_counter: int;

func init_piece(
	type: Globals.PIECE_TYPES,
	col: Globals.COLORS,
	board_pos: Vector2,
	board
):
	piece_type = type
	color = col
	board_position = board_pos
	board_handle = board
	promoted = false;
	moved = false
	stun_counter = 0
	
	update_sprite()
	
	position = Vector2(
		X_OFFSET + board_position[0] * CELL_SIZE,
		Y_OFFSET + board_position[1] * CELL_SIZE,
	)
	
func update_sprite():
	if sprite:
		var region_pos = Globals.SPRITE_MAPPING[color][piece_type]
		sprite.region_rect = Rect2(
			region_pos.y * SPRITE_SIZE,
			region_pos.x * SPRITE_SIZE,
			SPRITE_SIZE,
			SPRITE_SIZE
		)

func move_position(to_move: Vector2):
	var old_pos = board_position #For moving Mitosis Pawn
	moved = true
	board_position = to_move
	position = Vector2(
		X_OFFSET + board_position[0] * CELL_SIZE,
		Y_OFFSET + board_position[1] * CELL_SIZE
	)
	
	# Handling Mitosis piece movement
	if piece_type == Globals.PIECE_TYPES.MITOSIS_PAWN:
		var dx = int(to_move.x - old_pos.x)
		var dy = int(to_move.y - old_pos.y)
		if abs(dx) == 2 and dy == 0:
			var mid_pos = Vector2(old_pos.x, old_pos.y)
			perform_mitosis(mid_pos)
			return
	
	# Update king position if they are moved
	if piece_type == Globals.PIECE_TYPES.SHIELD_KING:
		board_handle.register_king(board_position, color)
	
	# Promotion for pawns to KING BEHAVIOR
	if (piece_type == Globals.PIECE_TYPES.PAWN or piece_type == Globals.PIECE_TYPES.MITOSIS_PAWN or piece_type == Globals.PIECE_TYPES.WORM or piece_type == Globals.PIECE_TYPES.CHECKER) and (
		(color == Globals.COLORS.BLACK and to_move[1] == 5) or 
		(color == Globals.COLORS.WHITE and to_move[1] == 0)
	):
		#piece_type = Globals.PIECE_TYPES.PROMOTED_PAWN
		promoted = true
		update_sprite()
		
	#if piece_type == Globals.PIECE_TYPES.MITOSIS_PAWN and (
		#(color == Globals.COLORS.BLACK and to_move[1] == 5) or 
		#(color == Globals.COLORS.WHITE and to_move[1] == 0)
	#):
		#piece_type = Globals.PIECE_TYPES.KING
		#update_sprite()

func clone (_board):
	var piece = self.duplicate()
	piece.board_handle = _board
	return piece
	
func get_moveable_positions():
	match piece_type:
		Globals.PIECE_TYPES.PAWN: 
			if promoted:
				return king_threat_pos()
			return pawn_move_pos()
		Globals.PIECE_TYPES.MITOSIS_PAWN: 
			var ret = pawn_move_pos()
			if promoted:
				ret += king_threat_pos()
			ret += get_mitosis_positions()
			return ret
		Globals.PIECE_TYPES.BISHOP: return bishop_threat_pos()
		Globals.PIECE_TYPES.ROOK: return rook_threat_pos()
		Globals.PIECE_TYPES.KNIGHT: return knight_threat_pos()
		Globals.PIECE_TYPES.KING: return king_threat_pos()
		Globals.PIECE_TYPES.HORSE_ARCHER: return horse_archer_threat_pos()
		Globals.PIECE_TYPES.ARCHBISHOP: return archbishop_threat_pos()
		Globals.PIECE_TYPES.STUN_KNIGHT: return knight_threat_pos()
		Globals.PIECE_TYPES.TROJAN_HORSE: return knight_threat_pos()
		Globals.PIECE_TYPES.EXPLODING_BISHOP: return bishop_threat_pos()
		Globals.PIECE_TYPES.SHIELD_KING: return king_threat_pos()
		Globals.PIECE_TYPES.JOUST_BISHOP: return bishop_threat_pos()
		Globals.PIECE_TYPES.ACROBISHOP: return acrobishop_threat_pos()
		Globals.PIECE_TYPES.WORM: 
			var positions = pawn_move_pos()
			positions += worm_move_pos()
			if promoted:
				positions += king_threat_pos()
			return positions
		Globals.PIECE_TYPES.DUCK: return duck_move_pos()
		Globals.PIECE_TYPES.CHECKER: 
			return pawn_move_pos()
		_: return []

func get_threatened_positions():
	match piece_type:
		Globals.PIECE_TYPES.PAWN: 
			if promoted == true:
				return king_threat_pos()
			return pawn_threat_pos()
		Globals.PIECE_TYPES.MITOSIS_PAWN: 
			if promoted == true:
				return king_threat_pos()
			return pawn_threat_pos()
		Globals.PIECE_TYPES.BISHOP: return bishop_threat_pos()
		Globals.PIECE_TYPES.ROOK: return rook_threat_pos()
		Globals.PIECE_TYPES.KNIGHT: return knight_threat_pos()
		Globals.PIECE_TYPES.KING: return king_threat_pos()
		Globals.PIECE_TYPES.HORSE_ARCHER: return horse_archer_threat_pos()
		Globals.PIECE_TYPES.ARCHBISHOP: return archbishop_threat_pos()
		Globals.PIECE_TYPES.STUN_KNIGHT: return knight_threat_pos()
		Globals.PIECE_TYPES.TROJAN_HORSE: return knight_threat_pos()
		Globals.PIECE_TYPES.EXPLODING_BISHOP: return bishop_threat_pos()
		Globals.PIECE_TYPES.SHIELD_KING: return king_threat_pos()
		Globals.PIECE_TYPES.JOUST_BISHOP: return bishop_threat_pos()
		Globals.PIECE_TYPES.ACROBISHOP: return acrobishop_threat_pos()
		Globals.PIECE_TYPES.WORM: 
			var positions = pawn_threat_pos()
			positions += worm_threat_pos()
			if promoted:
				positions += king_threat_pos()
			return positions
		Globals.PIECE_TYPES.DUCK: return []
		Globals.PIECE_TYPES.CHECKER: return checker_threat_pos(false)
		_: return []


# Pawn Moves
const PAWN_SPOT_INCREMENTS_MOVE = [[0, 1]] # Pawn move only one
const PAWN_SPOT_INCREMENTS_MOVE_FIRST = [[0, 1], [0, 2]] # Pawn can move one and two times initially
const PAWN_SPOT_INCREMENTS_TAKE = [[-1, 1], [1, 1]] # Pawn taking other piece at side 

func pawn_threat_pos():
	var positions = []
	
	for inc in PAWN_SPOT_INCREMENTS_TAKE:
		var pos = board_handle.spot_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1] if color == Globals.COLORS.BLACK else -inc[1],
			true, false
		)
		if pos != null:
			positions.append(pos)
	
	return positions

func pawn_move_pos():
	var positions = []
	
	var increments = PAWN_SPOT_INCREMENTS_MOVE if moved else PAWN_SPOT_INCREMENTS_MOVE_FIRST
	for inc in increments:
		var pos = board_handle.spot_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1] if color == Globals.COLORS.BLACK else -inc[1],
			false, true
		)
		if pos != null:
			positions.append(pos)
		else:
			# if there is something blocking in 1st pos
			# then second pos can't be moved
			break
		
	for inc in PAWN_SPOT_INCREMENTS_TAKE:
		var pos = board_handle.spot_search_threat(
			color, 
			board_position[0], board_position[1],
			inc[0], inc[1] if color == Globals.COLORS.BLACK else -inc[1],
			true, false
		)
		if pos != null and piece_type != Globals.PIECE_TYPES.CHECKER:
			positions.append(pos)
	
	return positions
	
const WORM_SPOT_THREAT_INCREMENTS = [[-5,1], [5, 1]];
const WORM_SPOT_THREAT_OPPOSITE_INCREMENTS = [[-5,-1], [5, -1]];
const WORM_SPOT_MOVE_INCREMENTS = [[-5,0], [5, 0], [-1, 0], [1, 0]];
func worm_threat_pos():
	var positions = []
	var WORM_INCREMENTS = WORM_SPOT_THREAT_INCREMENTS
	if promoted:
		WORM_INCREMENTS += WORM_SPOT_THREAT_OPPOSITE_INCREMENTS
	for inc in WORM_INCREMENTS:
		var pos = board_handle.spot_search_threat(
			color, 
			board_position[0], board_position[1],
			inc[0], inc[1] if color == Globals.COLORS.BLACK and !promoted else -inc[1],
			true, false
		)
		if pos != null:
			positions.append(pos)
	return positions
	
func worm_move_pos():
	var positions = []
	for inc in WORM_SPOT_MOVE_INCREMENTS:
		var pos = board_handle.spot_search_threat(
			color, 
			board_position[0], board_position[1],
			inc[0], inc[1] if color == Globals.COLORS.BLACK else -inc[1],
			false, true
		)
		if pos != null:
			positions.append(pos)
	return positions

# Bishop Moves
const BISHOP_BEAM_INCREMENTS = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
func bishop_threat_pos():
	var positions = []
	for inc in BISHOP_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
	return positions

# Rook Moves
const ROOK_BEAM_INCREMENTS = [[0, 1], [0, -1], [1, 0], [-1, 0]]
func rook_threat_pos():
	var positions = []
	for inc in ROOK_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
	return positions

# Knight Moves
const KNIGHT_SPOT_INCREMENTS = [[2,1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]];
func knight_threat_pos():
	var positions = []
	for inc in KNIGHT_SPOT_INCREMENTS:
		var pos = board_handle.spot_search_threat(
			color, 
			board_position[0], board_position[1],
			inc[0], inc[1] 
		)
		if pos != null:
			positions.append(pos)
	return positions


# Queen Moves
const QUEEN_BEAM_INCREMENTS = [[1, 1], [1, -1], [-1, 1], [-1, -1], [0, 1], [0, -1], [1, 0], [-1, 0]];
func queen_threat_pos():
	var positions = []
	for inc in QUEEN_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
	return positions
	
func duck_move_pos():
	var positions = []
	for inc in QUEEN_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
	return positions

# King Moves
const KING_SPOT_INCREMENTS = [[1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1]];
func king_threat_pos():
	var positions = []
	for inc in KING_SPOT_INCREMENTS:
		var pos = board_handle.spot_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
		if pos != null:
			positions.append(pos)
	return positions

# Horse Archer Moves
const HORSE_ARCHER_SPOT_INCREMENTS = [[2,1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]];
func horse_archer_threat_pos():
	var positions = []
	for inc in HORSE_ARCHER_SPOT_INCREMENTS:
		var pos = board_handle.spot_search_threat(
			color, 
			board_position[0], board_position[1],
			inc[0], inc[1] 
		)
		if pos != null:
			positions.append(pos)
	return positions
	
	
# Arch Bishop Moves
const ARCHBISHOP_BEAM_INCREMENTS = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
const ARCHBISHOP_SPOT_INCREMENTS = [[0, 1], [1, 0], [0, -1], [-1, 0]]
func archbishop_threat_pos():
	var positions = []
	for inc in ARCHBISHOP_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
	for inc in ARCHBISHOP_SPOT_INCREMENTS:
		var pos = board_handle.spot_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
		if pos != null:
			positions.append(pos)
	return positions
	
# ACRO Bishop Moves
const ACROBISHOP_SPOT_INCREMENTS = [[2, 2], [2, -2], [-2, 2], [-2, -2], [1, 1], [1, -1], [-1, 1], [-1, -1]]
func acrobishop_threat_pos():
	var positions = []
	for inc in ACROBISHOP_SPOT_INCREMENTS:
		var pos = board_handle.spot_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
		if pos != null:
			positions.append(pos)
	return positions

func get_mitosis_positions():
	var positions = []
	var current_x = int(board_position.x)
	var current_y = int(board_position.y)
	
	for dir in [-1, 1]:
		var mid = Vector2(current_x + dir, current_y )
		var dest = Vector2(current_x + 2 * dir, current_y)
		if board_handle.is_within_bounds(mid) and board_handle.is_within_bounds(dest):
			if board_handle.get_piece(dest) == null:
				positions.append(dest)
	return positions
	
func perform_mitosis(new_pawn_pos: Vector2):
	piece_type = Globals.PIECE_TYPES.PAWN
	update_sprite()
	
	board_handle.create_piece(
		Globals.PIECE_TYPES.PAWN,
		color,
		new_pawn_pos
	)

# Stun Knight Stun Search
const STUN_KNIGHT_RANGE_INCREMENT = [[0, 1], [1, 0], [0, -1], [-1, 0]]
func get_stun_positions():
	var positions = []
	for inc in STUN_KNIGHT_RANGE_INCREMENT:
		var pos = board_handle.spot_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
		if pos != null:
			positions.append(pos)
	return positions
	

# Trojan Horse Spawn Search
const TROJAN_SPAWN_INCREMENT = [[1, 0], [-1, 0]]
func get_trojan_spawn_positions():
	var positions = []
	for inc in TROJAN_SPAWN_INCREMENT:
		var pos = board_handle.spot_search_threat(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
		if pos != null:
			positions.append(pos)
	return positions
	
func trojan_spawn(color):
	for position in get_trojan_spawn_positions():
		board_handle.create_piece(
			Globals.PIECE_TYPES.PAWN,
			color,
			position
		)

const BISHOP_EXPLODE_INCREMENT = [[1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1]]
func bishop_explode_positions():
	var positions = []
	for inc in BISHOP_EXPLODE_INCREMENT:
		var pos = board_handle.spot_search_explode(
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
		if pos != null:
			positions.append(pos)
	return positions

const SHIELD_KING_PROTECT_INCREMENTS = [[1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1]]
func shield_king_protect_positions():
	var positions = []
	for inc in SHIELD_KING_PROTECT_INCREMENTS:
		var pos = board_handle.spot_search_protect(
			color,
			board_position[0], board_position[1],
			inc[0], inc[1]
		)
		if pos != null:
			positions.append(pos)
	return positions

#Checker Jumped Piece Pos Return
func checker_threat_pos(capture_pos : bool):
	var positions = []
	var increments = get_checker_increments()
	
	for inc in increments:
		var take = inc.take
		var jump = inc.jump
		
		var take_pos = board_handle.spot_search_threat(
			color,
			board_position.x, board_position.y,
			take.x, take.y,
			true, false
		)
		
		if take_pos != null:
			var jump_pos = board_handle.spot_search_threat(
				color,
				board_position.x, board_position.y,
				jump.x, jump.y,
				false, true
			)
			
			if jump_pos != null:
				if capture_pos:
					positions.append(take_pos)
				else:
					positions.append(jump_pos)
				
	return positions

func get_checker_increments():
	var increments = []
	
	var direction = 1 if color == Globals.COLORS.BLACK else -1
	
	increments.append({"take": Vector2(-1, direction), "jump": Vector2(-2, direction * 2)})
	increments.append({"take": Vector2(1, direction), "jump": Vector2(2, direction * 2)})
	
	if promoted:
		increments.append({"take": Vector2(-1, -direction), "jump": Vector2(-2, -direction * 2)})
		increments.append({"take": Vector2(1, -direction), "jump": Vector2(2, -direction * 2)})
		
	return increments
