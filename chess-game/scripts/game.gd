class_name Game
extends Node2D

#var explosionScene = preload("res://scenes/Explosion.tscn")

# Game States
var game_over;
var player_color;
var status; # who is playing
var player2_type; # Where AI or Human is playinh
var white_shield_king = []
var black_shield_king = []

var current_map : int
var difficulty : Globals.DIFFICULTY
var ai_color : Globals.COLORS = Globals.COLORS.BLACK

var difficulty_dict : Dictionary

# To drag piece
var is_dragging: bool;
var selected_piece = null;
var previous_position = null;
var setup_complete: bool = false
var allow_select : bool = false
var failed_to_move : bool = false

@onready var board = $Board;
@onready var ui_control = $Control
@onready var win_label = $"Control/Win Label"
@onready var setup_ui = $SetupPhaseUI
@onready var loadout_ui = $loadoutSlots
@onready var descriptions: Control = $descriptions
@onready var loadouts_label: Label = $Loadouts_Label

@onready var turn_indicator : TextureRect = $TurnIndicator
@onready var sprite = $IndicatorImage

@onready var move_clock: Control = $move_clock
@onready var move_clock_2: Control = $move_clock2

@onready var captured_display: Control = $captured_display
@onready var captured_display_2: Control = $captured_display2

@onready var main_menu_button: DynamicButton = $Control/MainMenu_Button
@onready var upper_resign_button: DynamicButton = $Upper_Resign_Button
@onready var lower_resign_button: DynamicButton = $Lower_Resign_Button

@onready var setting_indicator: LoadingIndicator = $setting_indicator
@onready var thinking_indicator: LoadingIndicator = $thinking_indicator

@onready var confirm_button: DynamicButton = $Confirm_Button

const MOVE_CLOCK_OFFSET : float = 300.0


var move_time : float
var time_remaining : float

const EASY_TIME : float = 21.0
const NORMAL_TIME : float = 14.0
const HARD_TIME : float = 7.0

const MAX_TURNS_WITHOUT_CAPTURE := 100
var turns_since_last_capture := 0
var previous_piece_total := 0

const SELECTION_BOX_COLOR = Color(0.0, 0.723, 0.736, 1.0)
const PREVIOUS_MOVE_COLOR = Color(0.25, 1.0, 0.0, 0.1)

var board_repr = []

var real_game : bool = true
var online_game : bool = false
var setup_piece_died : bool = false

var LOWER_COLOR : Globals.COLORS = Globals.COLORS.WHITE
var UPPER_COLOR : Globals.COLORS = Globals.COLORS.BLACK

const EVAL_DIVISOR : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	ui_control.hide()
	win_label.hide()
	turn_indicator.hide()
	init_game()
	
	descriptions.show()
	loadout_ui.show()
	setup_complete = false
	allow_select = true
	
	SignalBus.set_status.connect(_on_board_set_status)
	SignalBus.spawn_ai.connect(_on_board_spawn_ai)
	SignalBus.setup_complete.connect(_on_board_setup_complete)
	SignalBus.loadout_button.connect(loadout_button_pressed)
	SignalBus.piece_moved.connect(_on_piece_moved)
	SignalBus.trojan_spawned.connect(_on_trojan_spawned)
	SignalBus.mitosis_spawned.connect(_on_mitosis_spawned)
	SignalBus.show_notification.connect(show_notification)
	SignalBus.move_clock_expired.connect(process_expired_clock)
	
	SignalBus.piece_added.connect(on_setup_board_updated)
	SignalBus.piece_refunded.connect(on_setup_board_updated)
	
	main_menu_button.button_triggered.connect(_on_button_pressed)
	upper_resign_button.button_triggered.connect(on_resign)
	lower_resign_button.button_triggered.connect(on_resign)
	if online_game:
		confirm_button.button_triggered.connect(on_confirm_loadout.rpc)
	else:
		confirm_button.button_triggered.connect(on_confirm_loadout)
	
	lower_resign_button.hide()
	upper_resign_button.hide()
	
	multiplayer.peer_disconnected.connect(on_player_disconnect)
	multiplayer.server_disconnected.connect(on_server_disconnect)
	
	difficulty_dict = difficulty_settings()
	
	board_vector = Vector2(board.BOARD_WIDTH - 1, board.BOARD_HEIGHT - 1)
	
	thinking_indicator.hide()
	confirm_button.hide()
	setting_indicator.hide()
	
	if ai_color == Globals.COLORS.WHITE:
		LOWER_COLOR = Globals.COLORS.BLACK
		UPPER_COLOR = Globals.COLORS.WHITE
		board.LOWER_COLOR = Globals.COLORS.BLACK
		board.UPPER_COLOR = Globals.COLORS.WHITE
		
		move_clock.global_position.y -= MOVE_CLOCK_OFFSET
		move_clock_2.global_position.y += MOVE_CLOCK_OFFSET
		
		captured_display.color = Globals.COLORS.WHITE
		captured_display_2.color = Globals.COLORS.BLACK
		
		board._on_game_init_ai(Globals.COLORS.WHITE)
	elif !online_game:
		move_clock.global_position.y += MOVE_CLOCK_OFFSET
		move_clock_2.global_position.y -= MOVE_CLOCK_OFFSET
	
	if online_game:
		player_color = Network.my_color
		player2_type = Globals.PLAYER_2_TYPE.NETWORK
		
		Network.network_print("my color : " + str(player_color))
		
		if player_color == Globals.COLORS.BLACK:
			LOWER_COLOR = Globals.COLORS.BLACK
			UPPER_COLOR = Globals.COLORS.WHITE
			board.LOWER_COLOR = Globals.COLORS.BLACK
			board.UPPER_COLOR = Globals.COLORS.WHITE
			
			move_clock.global_position.y -= MOVE_CLOCK_OFFSET
			move_clock_2.global_position.y += MOVE_CLOCK_OFFSET
			
			captured_display.color = Globals.COLORS.WHITE
			captured_display_2.color = Globals.COLORS.BLACK
			
			descriptions.hide()
			loadout_ui.hide()
			setting_indicator.show()
		else:
			move_clock.global_position.y += MOVE_CLOCK_OFFSET
			move_clock_2.global_position.y -= MOVE_CLOCK_OFFSET
	
	$evaluation_bar.set_value(5.0)
	if player_color == Globals.COLORS.BLACK:
		$evaluation_bar.fill_mode_TTB()
		
	if status == LOWER_COLOR:
		board.draw_selection_box(Vector2(0.0, 5.0), Vector2(7.0, 7.0), SELECTION_BOX_COLOR)
	else:
		board.draw_selection_box(Vector2(0.0, 0.0), Vector2(7.0, 2.0), SELECTION_BOX_COLOR)
	
func difficulty_settings() -> Dictionary:
	match difficulty:
		Globals.DIFFICULTY.EASY:
			set_clock_durations(3.0)
			return {"depth" : 1, "noise" : 2.0, "slice_num" : 9}
		Globals.DIFFICULTY.NORMAL:
			set_clock_durations(2.0)
			return {"depth" : 2, "noise" : 1.0, "slice_num" : 3}
		Globals.DIFFICULTY.HARD:
			set_clock_durations(1.0)
			return {"depth" : 2, "noise" : 0.0, "slice_num" : 3}
	return {"depth" : 3, "noise" : 0.0, "slice_num" : 3}

func show_notification(phrase : String):
	$notification.set_text(phrase)
	
func loadout_button_pressed(loadout):
	if online_game and status != Network.my_color:
		return
	
	var save_string : String
	if status == Globals.COLORS.WHITE:
		board.wipe_pieces(true, false)
	else:
		board.wipe_pieces(false, true)
	
	if loadout == 1:
		save_string = LoadoutSaves.loadouts_to_save.loadout1
	elif loadout == 2:
		save_string = LoadoutSaves.loadouts_to_save.loadout2
	else:
		save_string = LoadoutSaves.loadouts_to_save.loadout3
	parse_save_string(save_string)
	$loadoutSlots.clear_selected()

@rpc("any_peer", "reliable")
func network_process_save_string(save_string, color):
	Network.network_print("network_process_save_string received: color=%s my_color=%s string=%s" % [color, Network.my_color, save_string])
	if color == Network.my_color:
		Network.network_print("Skipping - this is my own pieces")
		return
		
	#var old_status = status
	#status = color
	#Network.network_print("Parsing with status=%s" % status)
	parse_save_string(save_string)
	#status = old_status
	
	$loadoutSlots.clear_selected()

func parse_save_string(save_string):
	var spawn_array = save_string.split("_", false)
	var status_equal = status == LOWER_COLOR
	for spawn in spawn_array:
		var spawn_split = spawn.split(":")
		var coord_split = spawn_split[1].split(",")
		if status_equal:
			board.selected_pos = Vector2(int(coord_split[0]) + 1,int(coord_split[1]))
		else:
			board.selected_pos = Vector2(int(coord_split[0]) * -1 + 5,int(coord_split[1]) * -1 + 6)
		board._on_setup_phase_ui_spawn_piece(int(spawn_split[0]))

var previous_square
var current_square
var color_to_be_moved : Globals.COLORS
var square

func _input(event):
	if game_over:
		return
	# Mouse left clicks/drags
	if Input.is_action_just_pressed("left_click"):
		square = get_square_under_mouse()
		previous_square = square
		selected_piece = board.get_piece(square)
		
		# Drag piece only if they are under the mouse or are of current player
		if !allow_select:
			return
			
		if selected_piece == null and !setup_complete:
			if square.x < board.BOARD_WIDTH and square.x > -1 and square.y < board.BOARD_HEIGHT and square.y > -1:
				if player2_type != Globals.PLAYER_2_TYPE.NETWORK or status == Network.my_color:
					if status == LOWER_COLOR and square.y >= board.BOARD_HEIGHT - 2:
						SignalBus.emit_signal("selected_square", square)
					if status == UPPER_COLOR and square.y <= 1:
						SignalBus.emit_signal("selected_square", square)
			return
			
		if selected_piece != null and !setup_complete and selected_piece.color == status and (player2_type != Globals.PLAYER_2_TYPE.NETWORK or status == Network.my_color):
			SignalBus.emit_signal("selected_square", Vector2(-1, -1))
			is_dragging = true
			previous_position = selected_piece.position
			selected_piece.z_index = 100
			selected_piece.play_animation("sway")
			return
			
		if selected_piece:
			if selected_piece.color != status or selected_piece.stun_counter != 0 or (player2_type == Globals.PLAYER_2_TYPE.NETWORK and status != Network.my_color):
				return
			
		if !setup_complete or !selected_piece:
			return
			
		is_dragging = true
		selected_piece.play_animation("sway")
		previous_position = selected_piece.position
		selected_piece.z_index = 100
		
		# Highlights available moves
		var highlight_moves = selected_piece.get_moveable_positions() + selected_piece.get_threatened_positions()
		for it in highlight_moves:
			var color : Color
			var dest_piece = board.get_piece(Vector2(it.x, it.y))
			if dest_piece != null and !board.piece_is_protected(dest_piece) and (dest_piece.color != Globals.COLORS.TILE or dest_piece.piece_type == Globals.PIECE_TYPES.WEB):
				if dest_piece.color == selected_piece.color:
					color = Color(0.0, 0.648, 0.158, 0.5)
					dest_piece.play_animation("sway")
					board.draw_border(it.x, it.y, color, false, Globals.BORDER_STYLE.FRIENDLY)
				else:
					color = Color(1.0, 0.0, 0.0, 0.3)
					dest_piece.play_animation("cower")
					board.draw_border(it.x, it.y, color, false, Globals.BORDER_STYLE.TARGET)
			elif dest_piece == null:
				color = Color(1.0, 1.0, 0.0, 0.3)
				board.draw_border(it.x, it.y, color, false, Globals.BORDER_STYLE.CIRCLE)
				
	elif event is InputEventMouseMotion and is_dragging:
		var piece_mouse_pos = get_global_mouse_position() - board.global_position
		#piece_mouse_pos.y += 40
		selected_piece.position = piece_mouse_pos
	elif Input.is_action_just_released("left_click") and is_dragging:
		if !setup_complete:
			if !selected_piece:
				return
			
			selected_piece.play_animation("idle")
			selected_piece.z_index = 0
			is_dragging = false
			
			var is_valid_move = setup_drop_piece()
			
			if setup_piece_died:
				ExplodingBishop.spawn_explosion_literal(selected_piece.position + board.global_position)
				
				board.delete_piece(selected_piece, true, true)
				setup_ui._on_board_refund_piece(selected_piece.piece_type)
				setup_piece_died = false
			
			if !is_valid_move:
				selected_piece.position = previous_position
			
			selected_piece = null
			square = null
			return
		
		board.clear_borders()
		clear_piece_animations()
		
		if selected_piece:
			selected_piece.play_animation("idle")
		
		selected_piece.z_index = 0
		is_dragging = false
		
		var to_move = get_square_under_mouse()
		if status == player_color and player2_type == Globals.PLAYER_2_TYPE.NETWORK:
			selected_piece.position = previous_position
			request_move(previous_square, to_move)
		else:
			var is_valid_move = drop_piece()
			if !is_valid_move:
				selected_piece.position = previous_position
			if real_game:
				# Check whether game is over after user's move
				if evaluate_end_game():
					return
				
				# If playerA has made valid move, then switch to other player's move
				if is_valid_move:
					player2_move()
		
		selected_piece = null

func clear_piece_animations():
	for piece in board.pieces:
		piece.play_animation("idle")

func setup_drop_piece() -> bool:
	var drop_square = get_square_under_mouse()
	if !setup_is_within_bounds(drop_square, selected_piece.color):
		print("drop square x: ", drop_square.x)
		if drop_square.x > 7 or drop_square.x < -1:
			setup_piece_died = true
		return false
	
	for piece in board.pieces:
		if piece != selected_piece and piece.board_position == drop_square:
			piece.move_position(selected_piece.board_position, true)
			selected_piece.move_position(drop_square, true)
			board.play_sound("capture")
			return true
	
	selected_piece.move_position(drop_square, true)
	board.play_sound("move")
	return true

func setup_is_within_bounds(pos : Vector2, color : Globals.COLORS):
	if color == LOWER_COLOR:
		return pos.x < board.BOARD_WIDTH and pos.x > -1 and pos.y > 4 and pos.y < 7
	return pos.x < board.BOARD_WIDTH and pos.x > -1 and pos.y > -1 and pos.y < 2

func init_game():
	game_over = false
	is_dragging = false
	if ai_color == Globals.COLORS.BLACK:
		player_color = Globals.COLORS.WHITE
	else:
		player_color = Globals.COLORS.BLACK
	status = Globals.COLORS.WHITE
	
	# Initialize the board represntation array
	board_repr.resize(board.BOARD_WIDTH * board.BOARD_HEIGHT)
	
	# Check to see if either player has a shield king.
	check_for_shield_king()

func check_for_shield_king():
	for piece in board.pieces:
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.WHITE:
			white_shield_king.append(piece)
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.BLACK:
			black_shield_king.append(piece)

func get_square_under_mouse():
	var pos = get_global_mouse_position() - board.global_position
	pos.x = int(pos.x / board.CELL_SIZE)
	pos.y = int(pos.y / board.CELL_SIZE)
	return pos
	
func get_pos_under_mouse():
	var pos = get_global_mouse_position()
	pos.x = int(pos.x / board.CELL_SIZE)
	pos.y = int(pos.y / board.CELL_SIZE)
	return pos

func drop_piece(use_mouse = true, non_mouse_pos = Vector2(0,0)):
	var is_shooting = false
	var is_jousting = false
	var piece_died = false
	
	var to_move
	if use_mouse:
		to_move = get_square_under_mouse()
	else:
		to_move = non_mouse_pos
		
	var old_pos = selected_piece.board_position
	#var piece_around
	var checker_captured = false
	#var jumped
	#var jumped_piece_location
	var shield_king_killed = false
	var juggernaut_hit = false
	
	var piece_captured = false
	
	
	if valid_move(old_pos, to_move):
		# For valid move:
		# - if target has piece, then replace it
		var dest_piece = board.get_piece(to_move)
		# If piece is checker, delete the jumped piece
		if selected_piece.piece_type == Globals.PIECE_TYPES.CHECKER:
			var delta = to_move - old_pos
			if abs(int(delta.x)) == 2 and abs(int(delta.y)) == 2:
				var jumped_pos = Vector2(int((old_pos.x + to_move.x) / 2), int((old_pos.y + to_move.y) / 2))
				var jumped_piece = board.get_piece(jumped_pos)
				if jumped_piece != null and jumped_piece.color != selected_piece.color and jumped_piece.color != Globals.COLORS.TILE and jumped_piece.piece_type != Globals.PIECE_TYPES.DUCK:
					#if jumped_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
						#ExplodingBishop.explode_range(jumped_piece, board)
					#else:
					board.on_capture(jumped_piece, selected_piece, board, old_pos)
					piece_captured = true
					checker_captured = true
					dest_piece = null
					
		if selected_piece.piece_type == Globals.PIECE_TYPES.DUPLICATOR and dest_piece != null and dest_piece.color == selected_piece.color:
			Duplicator.Duplicate(selected_piece, dest_piece, board)
			is_shooting = true
			selected_piece.position = previous_position
		# Delete only if the target piece is of different color
		if dest_piece != null and dest_piece.color != selected_piece.color:
			if dest_piece.piece_type == Globals.PIECE_TYPES.JUGGERNAUT or dest_piece.piece_type == Globals.PIECE_TYPES.JUGGERNAUT2:
				juggernaut_hit = true
				selected_piece.position = previous_position
			#if selected_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
		if dest_piece != null and dest_piece.color != selected_piece.color: #and dest_piece.color != Globals.COLORS.TILE:
			if selected_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP and dest_piece.piece_type != Globals.PIECE_TYPES.WEB:
				shield_king_killed = ExplodingBishop.explode_king(dest_piece, selected_piece, board)
			if dest_piece.piece_type == Globals.PIECE_TYPES.JOUST_BISHOP and selected_piece.piece_type != Globals.PIECE_TYPES.HORSE_ARCHER:
				piece_died = true
			if selected_piece.piece_type == Globals.PIECE_TYPES.WARHORSE:
				Warhorse.WarhorseCapture(board, selected_piece, dest_piece)
			if not shield_king_killed:
				board.on_capture(dest_piece, selected_piece, board, old_pos)
				piece_captured = true
			#selected_piece.move_position(selected_piece.board_position)
			if selected_piece.piece_type == Globals.PIECE_TYPES.HORSE_ARCHER or (selected_piece.piece_type == Globals.PIECE_TYPES.INFECTOR and dest_piece.piece_type != Globals.PIECE_TYPES.WEB):
				is_shooting = true
				selected_piece.position = previous_position
			if selected_piece.piece_type == Globals.PIECE_TYPES.JOUST_BISHOP:
				if dest_piece.piece_type != Globals.PIECE_TYPES.EXPLODING_BISHOP and dest_piece.piece_type != Globals.PIECE_TYPES.JOUST_BISHOP:
					is_jousting = true
		if is_shooting == true or juggernaut_hit == true:
			current_square = dest_piece.board_position
		if is_shooting == false and juggernaut_hit == false:
			selected_piece.move_position(to_move)
			current_square = selected_piece.board_position
			if selected_piece.piece_type == Globals.PIECE_TYPES.STUN_KNIGHT:
				for space in selected_piece.get_stun_positions():
					var piece = board.get_piece(space)
					if piece != null and piece.color != Globals.COLORS.TILE:
						piece.stun_counter = 2
		#if selected_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
			#board.register_king(selected_piece.board_position, selected_piece.color)
		if piece_died:
			board.on_capture(selected_piece, dest_piece, board, old_pos)
		if is_jousting:
			var joust_pos = to_move + joust_direction(old_pos, to_move)
			dest_piece = board.get_piece(joust_pos)
			if dest_piece != null and valid_move(to_move, joust_pos) and dest_piece.piece_type != Globals.PIECE_TYPES.EXPLODING_BISHOP:
				board.on_capture(dest_piece, selected_piece, board, old_pos)
				piece_captured = true
				selected_piece.move_position(joust_pos)
				current_square = selected_piece.board_position
				
		if real_game and selected_piece:
			if online_game and Network.my_color == Globals.COLORS.BLACK:
				var flip_old_pos = abs(old_pos - Vector2(Board.BOARD_WIDTH, Board.BOARD_HEIGHT) + Vector2(1,1))
				var flip_to_move = abs(to_move - Vector2(Board.BOARD_WIDTH, Board.BOARD_HEIGHT) + Vector2(1,1))
				SignalBus.previous_move.emit(selected_piece.piece_type, selected_piece.color, flip_old_pos, flip_to_move)
			else:
				SignalBus.previous_move.emit(selected_piece.piece_type, selected_piece.color, old_pos, to_move)
				
		if piece_died:
			board.on_capture(selected_piece, dest_piece, board, old_pos)
		
		if real_game:
			if !piece_captured:
				board.play_sound("move")
			
			if !checker_captured:
				if player2_type == Globals.PLAYER_2_TYPE.NETWORK:
					if multiplayer.is_server():
						sync_end_turn.rpc()
				else:
					end_turn()
			else:
				board.update_indicators()
				player2_move()
				print("calling player2 move")
		print(board.shield_king)
		return true
	return false

func valid_move(from_pos, to_pos):
	var board_copy = board.clone()
	var src_piece = board_copy.get_piece(from_pos)
	#var shield_king_position
	#var shield_king
	
	# If we cannot move to threatend or moveable position
	if(
		to_pos not in src_piece.get_moveable_positions()
		and
		to_pos not in src_piece.get_threatened_positions()
	):
		return false
	
	var dest_piece = board.get_piece(to_pos)
	if dest_piece != null and ((board.piece_is_protected(dest_piece) && src_piece.piece_type != Globals.PIECE_TYPES.EXPLODING_BISHOP) or dest_piece.piece_type == Globals.PIECE_TYPES.DUCK or (dest_piece.color == Globals.COLORS.TILE and dest_piece.piece_type != Globals.PIECE_TYPES.WEB)):
		return false
			
	
	var dst_piece = board_copy.get_piece(to_pos)
	if dst_piece != null and (dst_piece.color != Globals.COLORS.TILE or dst_piece.piece_type == Globals.PIECE_TYPES.WEB):
		board_copy.delete_piece(dst_piece)
	#src_piece.move_position(to_pos)
	
	
	
	return true

# Determine the square the jousting bishop should go
func joust_direction(old_pos, to_move):
	var pos = Vector2(0, 0)
	
	if old_pos.x < to_move.x:
		pos.x = 1
	else:
		pos.x = -1
	
	if old_pos.y > to_move.y:
		pos.y = -1
	else:
		pos.y = 1
	
	return pos

func get_valid_moves():
	# Get possible moves for current player
	var valid_moves = []
#	var shield_king_position
#	var shield_king
	
	for piece in board.pieces:
		if piece.stun_counter > 0:
			continue
		if piece.color == status:
			var candi_pos = piece.get_moveable_positions()
			if piece.piece_type == Globals.PIECE_TYPES.PAWN:
				candi_pos += piece.get_threatened_positions()
			candi_pos = unique(candi_pos)
			for pos in candi_pos:
				if valid_move(piece.board_position, pos):
					valid_moves.append([piece, pos])
#		if status == Globals.COLORS.WHITE && black_shield_king_alive:
#			shield_king_position = board.black_king_pos
#			shield_king = board.get_piece(shield_king_position)
#		elif status == Globals.COLORS.BLACK && white_shield_king_alive:
#			shield_king_position = board.white_king_pos
#			shield_king = board.get_piece(shield_king_position)
#		if piece.piece_type != Globals.PIECE_TYPES.EXPLODING_BISHOP && shield_king != null:
#			for move in valid_moves:
#				for position in shield_king.shield_king_protect_positions():
#					var index = valid_moves.find(move)
#					if valid_moves[index][1] == position:
#						valid_moves.remove_at(index)
	return valid_moves

func unique(arr: Array) -> Array: 
	var dict = {}
	for a in arr:
		dict[a] = 1
	return dict.keys()

const MINIMUM_WAIT_TIME : float = 1.0
const MAXIMUM_WAIT_TIME : float = 3.0

func player2_move():
	print("player2 reached")
	print("real game: ", real_game)
	print("player 2 type: ", player2_type)
	
	if real_game and player2_type == Globals.PLAYER_2_TYPE.AI:
		#board.clear_borders()
		#clear_piece_animations()
		
		thinking_indicator.show()
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		# REVISIT
		var wait_time = randf_range(MINIMUM_WAIT_TIME, MAXIMUM_WAIT_TIME)
		await get_tree().create_timer(wait_time).timeout
		
		var minimax_result = Ai.start_minimax(board.pieces, true if status == Globals.COLORS.WHITE else false, difficulty_dict)
		print("RESULT: ", minimax_result)
		
		var new_piece = minimax_result["ref"]
		if !new_piece:
			push_error("Minimax failed to find a move")
			evaluate_end_game()
			return
		print("PIECE TYPE: ", Globals.PIECE_TYPES.keys()[new_piece.piece_type])
		
		var real_piece = board.get_piece(new_piece.board_position)
		if real_piece == null:
			push_error("Could not find piece at position")
			return
		if real_piece.piece_type != new_piece.piece_type or real_piece.color != new_piece.color:
			push_error("Found wrong piece - expected: ", Globals.PIECE_TYPES.keys()[new_piece.piece_type], 
					   " got: ", Globals.PIECE_TYPES.keys()[real_piece.piece_type])
			return
		
		selected_piece = real_piece
		previous_position = selected_piece.position
		previous_square = selected_piece.board_position
		print ("drop_piece result: ", drop_piece(false, minimax_result["pos"]))
		
		thinking_indicator.hide()

func evaluate_end_game():
	# Check whether the current user can make any legal move
	var moves = get_valid_moves()
	if len(moves) == 0:
		game_over = true
		stop_clocks()
		set_win(status)
		return true
		
	# Check if Duck is only remaining piece
	var white_piece_count : int = 0
	var white_duck : bool = false
	var black_piece_count : int = 0
	var black_duck : bool = false
	for piece in board.pieces:
		if piece.color == Globals.COLORS.WHITE:
			white_piece_count += 1
			if piece.piece_type == Globals.PIECE_TYPES.DUCK:
				white_duck = true
		elif piece.color == Globals.COLORS.BLACK:
			black_piece_count += 1
			if piece.piece_type == Globals.PIECE_TYPES.DUCK:
				black_duck = true
				
	if white_piece_count == 1 and white_duck or black_piece_count == 1 and black_duck:
		game_over = true
		stop_clocks()
		set_win(status)
		return true
		
	if turns_since_last_capture > MAX_TURNS_WITHOUT_CAPTURE:
		game_over = true
		stop_clocks()
		set_win(null)
		return true
		
			
	return false

func set_win(color):
	game_over = true
	if color == Globals.COLORS.WHITE:
		win_label.text = "BLACK WON"
	elif color == Globals.COLORS.BLACK:
		win_label.text = "WHITE WON"
	else:
		win_label.text = "DRAW"
	win_label.show()
	ui_control.show()
	
	upper_resign_button.hide()
	lower_resign_button.hide()
	
#func spawn_explosion(pos : Vector2):
	#var actual_pos = Vector2(pos.x * 120 + 60, pos.y * 120 + 60)
	#var explosion = explosionScene.instantiate()
	#explosion.position = actual_pos
	#add_child(explosion)


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func end_turn():
	for piece in board.pieces:
		if piece.stun_counter > 0:
			piece.stun_counter -= 1
			if piece.infect_counter > 0:
				piece.infect_counter -= 1
				if piece.infect_counter == 0:
					if piece.color == Globals.COLORS.WHITE:
						piece.color = Globals.COLORS.BLACK
						piece.update_sprite()
					elif piece.color == Globals.COLORS.BLACK:
						piece.color = Globals.COLORS.WHITE
						piece.update_sprite()
					if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
						board.shield_king.append(piece)
		if piece.cool_counter > 0:
			piece.cool_counter -= 1
			if piece.cool_counter == 4:
				piece.piece_type = Globals.PIECE_TYPES.MAGMA_MED
				piece.update_sprite()
			elif piece.cool_counter == 2:
				piece.piece_type = Globals.PIECE_TYPES.MAGMA_LOW
				piece.update_sprite()
			elif piece.cool_counter == 0:
				board.delete_piece(piece)
	status = Globals.COLORS.BLACK if status == Globals.COLORS.WHITE else Globals.COLORS.WHITE
	
	if status == Globals.COLORS.WHITE:
		move_clock.start_turn()
		move_clock_2.end_turn()
	else:
		move_clock.end_turn()
		move_clock_2.start_turn()
	
	if real_game:
		turn_indicator.texture = get_turn_indicator_tex(status)
		
		board.clear_highlights()
		board.draw_highlight(previous_square.x, previous_square.y, PREVIOUS_MOVE_COLOR, false)
		board.draw_highlight(current_square.x, current_square.y, PREVIOUS_MOVE_COLOR, false)
	
	if board.num_pieces() == previous_piece_total:
		turns_since_last_capture += 1
	else:
		previous_piece_total = board.num_pieces()
		turns_since_last_capture = 0
	
	clear_piece_animations()
	check_for_shield_king()
	board.update_indicators()
	update_eval()
	toggle_resign_buttons()
	
func update_eval():
	var eval = Ai.board_evaluation(board.pieces, 0.0)
	var eval_normalized = 1.0 / (1.0 + exp(-eval / EVAL_DIVISOR))
	$evaluation_bar.set_target(eval_normalized)

func get_turn_indicator_tex(color):
	if sprite:
		var SPRITE_SIZE = 32
		var region_pos = Globals.SPRITE_MAPPING[color][Globals.PIECE_TYPES.PAWN]
		var region = Rect2(
			region_pos.y * SPRITE_SIZE,
			region_pos.x * SPRITE_SIZE,
			SPRITE_SIZE,
			SPRITE_SIZE
		)
		
		var atlas := AtlasTexture.new()
		atlas.atlas = sprite.texture
		atlas.region = region
		
		return atlas
	
func _on_board_setup_complete() -> void:
	setup_complete = true
	board.clear_selection_box()
	descriptions.hide()
	loadouts_label.hide()
	loadout_ui.hide()
	setting_indicator.hide()
	status = Globals.COLORS.WHITE
	init_pieces()
	board.update_indicators()
	turn_indicator.texture = get_turn_indicator_tex(status)
	turn_indicator.show()
	update_eval()
	
	move_clock.start_turn()
	toggle_resign_buttons()
	
	if ai_color == Globals.COLORS.WHITE:
		player2_move()
	
	for piece in board.pieces:
		board_repr[board.BOARD_WIDTH * piece.board_position[1] + piece.board_position[0]] = piece
	#for space in board_repr.size():
		#if board_repr[space] != null:
			#print(board_repr[space])

var previous_status : Globals.COLORS = Globals.COLORS.WHITE

func network_pass_board_pieces(color):
	if !online_game:
		return
	
	var save_string = ""
	
	for piece in board.pieces:
		if piece.color == color:
			save_string += str(piece.piece_type) + ":" + str(piece.board_position + Vector2(-1,0)) + "_"
	
	Network.network_print("network_pass_board_pieces: color=%s string=%s" % [color, save_string])
	network_process_save_string.rpc(save_string, color)
	print("calling network process")
	
	if Network.my_color == status and !setup_complete:
		descriptions.show()
		loadout_ui.show()
		setting_indicator.hide()
	else:
		descriptions.hide()
		loadout_ui.hide()
		setting_indicator.show()

func _on_board_set_status(color: Variant) -> void:
	print("attempted to set to: ", color)
	pass

func on_setup_board_updated() -> void:
	if !real_game or board.is_loadout_board or setup_complete:
		return
	
	print("checking for status: ", status)
	print("board count: ", board.num_pieces(status))
	if board.num_pieces(status) == Globals.PIECES_PER_SIDE and (!online_game or status == Network.my_color):
		if player2_type == Globals.PLAYER_2_TYPE.AI and ai_color == Globals.COLORS.WHITE and status == Globals.COLORS.WHITE:
			on_confirm_loadout()
			return
		
		confirm_button.show()
		if status == LOWER_COLOR:
			confirm_button.position = Vector2(819, 608)
		else:
			confirm_button.position = Vector2(819, 364)
		descriptions.hide()
		loadout_ui.hide()
	else:
		confirm_button.hide()
		if !online_game or status == Network.my_color:
			descriptions.show()
			loadout_ui.show()

@rpc("any_peer", "call_local")
func on_confirm_loadout() -> void:
	if online_game and status == Network.my_color:
		var save_string = ""
	
		for piece in board.pieces:
			if piece.color == status:
				save_string += str(piece.piece_type) + ":" + str(piece.board_position + Vector2(-1,0)) + "_"
		
		var confirming_color = status
		send_pieces_to_opponent.rpc_id(
			Network.opponent_id,
			confirming_color,
			save_string
		)
	
	previous_status = status
	status = Globals.COLORS.BLACK
	setup_ui.status = status
	board.clear_selection_box()
	if status == LOWER_COLOR:
		board.draw_selection_box(Vector2(0.0, 5.0), Vector2(7.0, 7.0), SELECTION_BOX_COLOR)
	else:
		board.draw_selection_box(Vector2(0.0, 0.0), Vector2(7.0, 2.0), SELECTION_BOX_COLOR)
	
	confirm_button.hide()
	if online_game:
		if Network.my_color == Globals.COLORS.BLACK:
			descriptions.show()
			descriptions.set_color(Globals.COLORS.BLACK)
			loadout_ui.show()
			setting_indicator.hide()
		else:
			descriptions.hide()
			loadout_ui.hide()
			setting_indicator.show()
		
		if previous_status == Globals.COLORS.BLACK and board.num_pieces() == Globals.PIECES_PER_SIDE * 2:
			_on_board_setup_complete()
	else:
		descriptions.show()
		descriptions.set_color(status)
		loadout_ui.show()
		
		if board.num_pieces() == Globals.PIECES_PER_SIDE * 2:
			_on_board_setup_complete()
		if board.num_pieces() == Globals.PIECES_PER_SIDE and player2_type == Globals.PLAYER_2_TYPE.AI and ai_color == Globals.COLORS.BLACK and status == Globals.COLORS.BLACK:
			SignalBus.emit_signal("spawn_ai")
			on_confirm_loadout()

@rpc("any_peer", "reliable")
func send_pieces_to_opponent(color : Globals.COLORS, save_string : String):
	Network.network_print("received pieces for color %s: %s" % [color, save_string])
	
	var old_status = status
	status = color
	Network.network_print("Parsing with status=%s" % status)
	parse_save_string(save_string)
	status = old_status
	loadout_ui.clear_selected()
	
	if color == Globals.COLORS.BLACK:
		_on_board_setup_complete()

func _on_board_spawn_ai() -> void:
	if player2_type == Globals.PLAYER_2_TYPE.AI:
		SignalBus.init_ai.emit(ai_color)

func init_pieces():
	board.register_king()

func _on_piece_moved(old_pos, new_pos):
	board_repr[board.BOARD_WIDTH * new_pos[1] + new_pos[0]] = board_repr[board.BOARD_WIDTH * old_pos[1] + old_pos[0]]
	board_repr[board.BOARD_WIDTH * old_pos[1] + old_pos[0]] = null

func _on_trojan_spawned(pos):
	board_repr[board.BOARD_WIDTH * position[1] + position[0]] = board.get_piece(pos)
	
func _on_mitosis_spawned(pos):
	board_repr[board.BOARD_WIDTH * position[1] + position[0]] = board.get_piece(pos)

# Timer code

func set_clock_durations(minutes : float) -> void:
	move_clock.set_duration(minutes)
	move_clock_2.set_duration(minutes)

func stop_clocks():
	move_clock.end_turn()
	move_clock_2.end_turn()

func process_expired_clock():
	game_over = true
	stop_clocks()
	set_win(status)
	return true

# Network code

var board_vector

func request_move(from_pos : Vector2, to_pos : Vector2):
	if !multiplayer.is_server():
		server_validate_move.rpc_id(1, abs(from_pos - board_vector), abs(to_pos - board_vector))
		Network.network_print("Attempting to validate move")
	else:
		if valid_move(from_pos, to_pos):
			apply_network_move.rpc(from_pos, to_pos)
			Network.network_print("request_move: Attempting to apply")

@rpc("any_peer", "reliable")
func server_validate_move(from_pos : Vector2, to_pos : Vector2):
	if !multiplayer.is_server():
		Network.network_print("server_validate_move: Not multiplayer server")
		return
	if valid_move(from_pos, to_pos):
		apply_network_move.rpc(from_pos, to_pos)
		Network.network_print("server_validate_move: Attempting to apply")

@rpc("authority", "call_local", "reliable")
func apply_network_move(from_pos : Vector2, to_pos : Vector2):
	var flip_from = from_pos
	var flip_to = to_pos
	
	if !multiplayer.is_server():
		flip_from = abs(from_pos - board_vector)
		flip_to = abs(to_pos - board_vector)
	
	var piece = board.get_piece(flip_from)
	if piece == null:
		return
	
	selected_piece = piece
	previous_position = piece.position
	previous_square = flip_from
	var message = "Drop piece from network : " + str(drop_piece(false, flip_to))
	Network.network_print(message)

@rpc("authority", "call_local", "reliable")
func sync_end_turn():
	Network.network_print("entered sync_end_turn()")
	for piece in board.pieces:
		if piece.stun_counter > 0:
			piece.stun_counter -= 1
			if piece.infect_counter > 0:
				piece.infect_counter -= 1
				if piece.infect_counter == 0:
					if piece.color == Globals.COLORS.WHITE:
						piece.color = Globals.COLORS.BLACK
						piece.update_sprite()
					elif piece.color == Globals.COLORS.BLACK:
						piece.color = Globals.COLORS.WHITE
						piece.update_sprite()
					if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
						board.shield_king.append(piece)
		if piece.cool_counter > 0:
			piece.cool_counter -= 1
			if piece.cool_counter == 4:
				piece.piece_type = Globals.PIECE_TYPES.MAGMA_MED
				piece.update_sprite()
			elif piece.cool_counter == 2:
				piece.piece_type = Globals.PIECE_TYPES.MAGMA_LOW
				piece.update_sprite()
			elif piece.cool_counter == 0:
				board.delete_piece(piece)
	status = Globals.COLORS.BLACK if status == Globals.COLORS.WHITE else Globals.COLORS.WHITE
	
	if status == Globals.COLORS.WHITE:
		move_clock.start_turn()
		move_clock_2.end_turn()
	else:
		move_clock.end_turn()
		move_clock_2.start_turn()
	
	if real_game:
		turn_indicator.texture = get_turn_indicator_tex(status)
		
		board.clear_highlights()
		board.draw_highlight(previous_square.x, previous_square.y, PREVIOUS_MOVE_COLOR, false)
		board.draw_highlight(current_square.x, current_square.y, PREVIOUS_MOVE_COLOR, false)
	
	if board.num_pieces() == previous_piece_total:
		turns_since_last_capture += 1
	else:
		previous_piece_total = board.num_pieces()
		turns_since_last_capture = 0
	
	clear_piece_animations()
	check_for_shield_king()
	board.update_indicators()
	update_eval()
	toggle_resign_buttons()
	
	evaluate_end_game()

@rpc("authority", "call_local", "reliable")
func sync_clocks(player_status : Globals.COLORS):
	if player_status == Globals.COLORS.WHITE:
		move_clock.start_turn()
		move_clock_2.end_turn()
	else:
		move_clock.end_turn()
		move_clock_2.start_turn()

func on_player_disconnect(_peer_id : int):
	if game_over:
		return
	game_over = true
	stop_clocks()
	set_win(flip_color(Network.my_color))
	return true

func on_server_disconnect():
	if game_over:
		return
	game_over = true
	stop_clocks()
	set_win(flip_color(Network.my_color))
	return true

# Resigning

func on_resign():
	if online_game:
		sync_resign.rpc()
		return
	
	game_over = true
	stop_clocks()
	set_win(status)
	return true

@rpc("any_peer", "call_local")
func sync_resign():
	game_over = true
	stop_clocks()
	set_win(status)
	Network.disconnect_game()
	return true

func toggle_resign_buttons():
	if online_game:
		if status == LOWER_COLOR:
			if status == Network.my_color:
				lower_resign_button.show()
			upper_resign_button.hide()
		else:
			lower_resign_button.hide()
			if status == Network.my_color:
				upper_resign_button.show()
		return
	
	if status == LOWER_COLOR:
		lower_resign_button.show()
		upper_resign_button.hide()
	else:
		lower_resign_button.hide()
		upper_resign_button.show()

func flip_color(color : Globals.COLORS):
	if color == Globals.COLORS.WHITE:
		return Globals.COLORS.BLACK
	return Globals.COLORS.WHITE
