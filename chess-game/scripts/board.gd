extends Node2D

@export var pieces = [];
@export var piece_scene = preload("res://scenes/Piece.tscn")
@export var setup_script = preload("res://scripts/setup_phase_ui.gd")
@export var status_indicator = preload("res://scenes/StatusIndicator.tscn")
const TILE_MAP = preload("res://tileMap.png")



@export var white_king_pos: Vector2 = Vector2(-2, -2)
@export var black_king_pos: Vector2 = Vector2(-2, -2)

var selected_pos: Vector2 = Vector2(-1, -1)
var setup_done: bool = false

enum BOARD_TYPE {
	STANDARD,
	RIVER,
	FOREST,
	WALL
}
var selected_board: BOARD_TYPE = BOARD_TYPE.STANDARD
const CELL_SIZE = 120

const BOARD_HEIGHT = 7
const BOARD_WIDTH = 7
const LOADOUT_X_OFFSET = 1
const LOADOUT_Y_OFFSET = 5

var is_loadout_board : bool = false

var first_color : Globals.COLORS
var second_color : Globals.COLORS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draw_board()
	if selected_board == BOARD_TYPE.RIVER:
		draw_river()
	elif selected_board == BOARD_TYPE.FOREST:
		draw_forest()
	elif selected_board == BOARD_TYPE.WALL:
		draw_wall()
	clear_borders()
	
	SignalBus.spawn_piece.connect(_on_setup_phase_ui_spawn_piece)
	SignalBus.init_ai.connect(_on_game_init_ai)
	SignalBus.selected_square.connect(_on_game_selected_square)

func draw_board():
	if !is_loadout_board:
		for x in range(BOARD_WIDTH):
			for y in range(BOARD_HEIGHT):
				draw_cell(x, y)
	else:
		for x in range(BOARD_WIDTH):
			for y in range(2):
				draw_cell(x + LOADOUT_X_OFFSET, y + LOADOUT_Y_OFFSET)
				
func draw_river():
	pass
	
func draw_forest():
	pass

func draw_wall():
	pass

func draw_cell(x, y):
	var rect = ColorRect.new()
	rect.color = Color(0.8, 0.6, 0.4) if (x + y) % 2 == 0 else Color(0.4, 0.3, 0.2)
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	rect.position = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	rect.z_index = -100
	add_child(rect)

func draw_water(x,y):
	var rect = ColorRect.new()
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	

func register_king(pos, col):
	match col:
		Globals.COLORS.WHITE:
			white_king_pos = pos
		Globals.COLORS.BLACK:
			black_king_pos = pos

func get_piece(pos: Vector2):
	if pieces.size() < 1:
		return
	for piece in pieces:
		if piece and piece.board_position == pos:
			return piece

func on_capture(dest_piece, selected_piece, board):
	if dest_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
		ExplodingBishop.explode_piece(dest_piece, selected_piece, board)
		delete_piece(selected_piece)
	elif dest_piece.piece_type == Globals.PIECE_TYPES.TROJAN_HORSE:
		TrojanHorse.trojan_spawn(dest_piece, board)
		delete_piece(dest_piece)
	delete_piece(dest_piece)
	
func delete_piece(piece, force = false):
	for i in range(len(pieces)):
		if pieces[i] == piece && (piece_is_protected(piece) == false or force):
			var popped = pieces.pop_at(i)
			popped.queue_free()
			return
			
func wipe_pieces(if_white = true, if_black = true):
	var pieces_to_remove = []
	for piece in pieces:
		if (if_white and piece.color == Globals.COLORS.WHITE) or (if_black and piece.color == Globals.COLORS.BLACK):
			pieces_to_remove.append(piece)
	
	for piece in pieces_to_remove:
		piece.queue_free()
		pieces.erase(piece)

func beam_search_threat(own_color, cur_x, cur_y, inc_x, inc_y):
	# Moves a pointer in a line in given inc_x/y direction
	# to find the thratened pieces
	var threat_pos = []
	var is_duck = false
	
	var check_piece = get_piece(Vector2(cur_x, cur_y))
	if check_piece.piece_type == Globals.PIECE_TYPES.DUCK:
		is_duck = true
	
	cur_x += inc_x
	cur_y += inc_y
	
	# Keep moving in increment direction to find either a blocked pieces
	# or out of board
	while is_within_bounds(Vector2(cur_x, cur_y)):
		var cur_pos = Vector2(cur_x, cur_y)
		var cur_piece = get_piece(cur_pos)
		if cur_piece != null:
			if cur_piece.color != own_color and cur_piece.piece_type != Globals.PIECE_TYPES.DUCK and !is_duck:
				threat_pos.append(cur_pos)
			break
		threat_pos.append(cur_pos)
		cur_x += inc_x
		cur_y += inc_y
	
	return threat_pos

func spot_search_threat(
	own_color, 
	cur_x, cur_y, 
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	# Do a single move and check if move is valid or threatens a piece
	cur_x += inc_x
	cur_y += inc_y
	
	if !is_within_bounds(Vector2(cur_x, cur_y)):
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	#if cur_piece != null and cur_piece.piece_type == Globals.PIECE_TYPES.DUCK:
		#return null
	
	if cur_piece != null:
		if free_only:
			return
		return cur_pos if cur_piece.color != own_color else null
	return cur_pos if not threat_only else null
	
func spot_search_explode( 
	cur_x, cur_y, 
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	# Do a single move and check if move is valid or threatens a piece
	cur_x += inc_x
	cur_y += inc_y
	
	if !is_within_bounds(Vector2(cur_x, cur_y)):
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	if cur_piece != null:
		if free_only:
			return
	return cur_pos if not threat_only else null
	
func spot_search_protect(
	own_color, 
	cur_x, cur_y, 
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	# Do a single move and check if move is valid or threatens a piece
	cur_x += inc_x
	cur_y += inc_y
	
	if !is_within_bounds(Vector2(cur_x, cur_y)):
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	if cur_piece != null:
		if free_only:
			return
		return cur_pos if cur_piece.color == own_color else null
	return cur_pos if not threat_only else null

func clone():
	var board = self.duplicate()
	for i in range(len(pieces)):
		var piece = pieces[i].clone(board)
		board.pieces[i] = piece
	return board
	
func is_within_bounds(pos: Vector2):
	return pos.x >= 0 and pos.x < BOARD_WIDTH and pos.y >= 0 and pos.y < BOARD_HEIGHT

func create_piece(type: Globals.PIECE_TYPES, col: Globals.COLORS, board_pos: Vector2):
	var piece = piece_scene.instantiate()
	add_child(piece)
	piece.init_piece(type, col, board_pos, self)
	pieces.append(piece)
	return piece

var border_panel
var borders = []

func _on_setup_phase_ui_spawn_piece(piece_type: Globals.PIECE_TYPES) -> void:
	print("hi from spawn_piece in board")
	if selected_pos == Vector2(-1, -1):
		print("Select a valid position")
		SignalBus.emit_signal("refund_piece", piece_type)
		return
	
	if is_loadout_board:
		selected_pos = Vector2(selected_pos.x - 1, selected_pos.y)
	
	if !is_within_bounds(selected_pos):
		print("Select an inbounds position")
		SignalBus.emit_signal("refund_piece", piece_type)
		return
		
	if is_loadout_board:
		selected_pos = Vector2(selected_pos.x + 1, selected_pos.y)
	
	if setup_done == true:
		print("Setup phase is over")
		return
		
	# Determine color for current piece
	var color
	var total_pieces : int = num_pieces()
	if total_pieces < Globals.PIECES_PER_SIDE:
		color = Globals.COLORS.WHITE
	elif !is_loadout_board:
		color = Globals.COLORS.BLACK
	create_piece(piece_type, color, selected_pos)
	print("Piece created")
	
	# Determine if color needs to swap
	if total_pieces + 1 < Globals.PIECES_PER_SIDE:
		color = Globals.COLORS.WHITE
	elif !is_loadout_board:
		color = Globals.COLORS.BLACK
		print("Color is now black")
	SignalBus.emit_signal("set_status", color)
	
	if total_pieces == Globals.PIECES_PER_SIDE - 1:
		SignalBus.emit_signal("spawn_ai")
		total_pieces = num_pieces()
	
	# Ready to play
	if total_pieces > (Globals.PIECES_PER_SIDE - 1) * 2:
		setup_done = true
		SignalBus.emit_signal("setup_complete")
		
	# Reset border visual and selected pos
	if border_panel and border_panel.is_inside_tree():
		border_panel.queue_free()
	selected_pos = Vector2(-1, -1)


func _on_game_selected_square(pos: Vector2) -> void:
	selected_pos = pos
	print("selected square = ", pos)
	if is_loadout_board:
		draw_border(pos.x, pos.y, Color(0.0, 1.0, 0.38, 1.0), true)
	else:
		draw_border(pos.x, pos.y, Color(0.0, 0.0, 1.0), true)
	
func draw_border(x, y, color, clear):
	if clear and border_panel and border_panel.is_inside_tree():
		border_panel.queue_free()
	border_panel = Panel.new()
	border_panel.size = Vector2(CELL_SIZE, CELL_SIZE)
	border_panel.position = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	border_panel.z_index = 50
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = color
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	border_panel.add_theme_stylebox_override("panel", style)
	
	add_child(border_panel)
	if !clear:
		borders.push_back(border_panel)
	
func clear_borders():
	for it in borders:
		it.queue_free()
	borders.clear()
	
var indicators = []
	
func spawn_indicator(pos : Vector2, status : String):
	var indicator = status_indicator.instantiate()
	var xOffset : int
	var yOffset : int
	if (status == "protected"):
		xOffset = 40
	else:
		xOffset = -40
	if (status == "promoted"):
		yOffset = 40
	else:
		yOffset = -40
	indicator.position = Vector2(pos.x * 120 + 60 + xOffset, pos.y * 120 + 60 + yOffset)
	indicator.z_index = 101
	indicator.set_status(status)
	add_child(indicator)
	indicators.push_back(indicator)
	
func clear_indicators():
	for it in indicators:
		it.queue_free()
	indicators.clear()
			
func update_indicators():
	clear_indicators()
	
	for piece in pieces:
		var pos = piece.board_position
		
		if piece.stun_counter > 0:
			spawn_indicator(pos, "stunned")
		if piece_is_protected(piece):
			spawn_indicator(pos, "protected")
		if piece.promoted:
			spawn_indicator(pos, "promoted")

func piece_is_protected(piece):
	var king_pos
	if piece.color == Globals.COLORS.WHITE:
		king_pos = white_king_pos
	else:
		king_pos = black_king_pos
		
	if piece.piece_type == Globals.PIECE_TYPES.DUCK:
		return true

	# Check if the king actually exists
	if king_pos == Vector2(-2, -2):
		return false

	var shield_king = get_piece(king_pos)
		
	if shield_king == null:
		return false
	
	
	return piece.board_position in shield_king.shield_king_protect_positions()


	
func num_pieces():
	var count : int = 0
	for piece in pieces:
		count += 1
	return count


func _on_game_init_ai(color) -> void:
	var piecesToSpawn = []
	piecesToSpawn = setup_script.determineAiPieces(color)
	
	var i = 0
	for it in piecesToSpawn.size() / 2:
		create_piece(piecesToSpawn[i], color, piecesToSpawn[i + 1])
		i += 2
		
	var colorSet
	var total_pieces : int = num_pieces()
	if total_pieces + 1 < Globals.PIECES_PER_SIDE:
		colorSet = Globals.COLORS.WHITE
	elif !is_loadout_board:
		colorSet = Globals.COLORS.BLACK
		print("Color is now black")
	SignalBus.emit_signal("set_status", colorSet)
