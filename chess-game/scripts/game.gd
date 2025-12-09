extends Node2D

signal selected_square(pos)
signal init_ai

var explosionScene = preload("res://scenes/Explosion.tscn")

# Game States
var game_over;
var player_color;
var status; # who is playing
var player2_type; # Where AI or Human is playinh
var white_shield_king_alive = false
var black_shield_king_alive = false

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
@onready var main_menu_ui = $MainMenu

@onready var move_timer : Timer = $MoveTimer
@onready var timer_label : Label = $TimerLabel
@onready var timer_bar : TextureProgressBar = $MoveTimerBar
var move_time := 15.0
var time_remaining := 15.0

# Called when the node enters the scene tree for the first time.
func _ready():
	ui_control.hide()
	win_label.hide()
	setup_ui.hide()
	timer_bar.hide()
	init_game()
	allow_select = false
	
func _on_opponent_ui_setup_ready() -> void:
	ui_control.hide()
	win_label.hide()
	setup_ui.show()
	setup_complete = false
	allow_select = true
	

func _input(event):
	if game_over:
		return
	# Mouse left clicks/drags
	if Input.is_action_just_pressed("left_click"):
		var pos = get_pos_under_mouse()
		selected_piece = board.get_piece(pos)
		# Drag piece only if they are under the mouse or are of current player
		if !allow_select:
			return
		
		if selected_piece == null and !setup_complete:
			if pos.x < 6 and pos.x > -1 and pos.y < 6 and pos.y > -1:
				if status == Globals.COLORS.WHITE and pos.y == 5:
					emit_signal("selected_square", pos)
				if status == Globals.COLORS.BLACK and pos.y == 0:
					emit_signal("selected_square", pos)
			else:
				print("no square was selected")
			return
			
		if selected_piece == null:
			return
			
		if selected_piece.color != status or selected_piece.stun_counter != 0:
			return
			
		if !setup_complete:
			return
			
		is_dragging = true
		previous_position = selected_piece.position
		selected_piece.z_index = 100
		
		# Highlights available moves
		var highlight_moves = selected_piece.get_moveable_positions() + selected_piece.get_threatened_positions()
		for it in highlight_moves:
			var color : Color
			var dest_piece = board.get_piece(Vector2(it.x, it.y))
			if dest_piece != null and !board.piece_is_protected(dest_piece):
				color = Color(1.0, 0.0, 0.0)
				board.draw_border(it.x, it.y, color, false)
			elif dest_piece == null:
				color = Color(1.0, 1.0, 0.0)
				board.draw_border(it.x, it.y, color, false)
				
			
	elif event is InputEventMouseMotion and is_dragging:
		selected_piece.position = get_global_mouse_position()
	elif Input.is_action_just_released("left_click") and is_dragging:
		var is_valid_move = drop_piece()
		if !is_valid_move:
			selected_piece.position = previous_position
		selected_piece.z_index = 0
		selected_piece = null
		is_dragging = false
		board.clear_borders()
		
		# Check whether game is over after user's move
		if evaluate_end_game():
			return
		
		
		# If playerA has made valid move, then switch to other player's move
		if is_valid_move:
			player2_move()

func init_game():
	game_over = false
	is_dragging = false
	player_color = Globals.COLORS.WHITE
	status = Globals.COLORS.WHITE
	# Check to see if either player has a shield king, and mark it alive if it does.
	for piece in board.pieces:
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.WHITE:
			white_shield_king_alive = true
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.BLACK:
			black_shield_king_alive = true
	#player2_type = Globals.PLAYER_2_TYPE.AI
	
	# Check to see if either player has a shield king, and mark it alive if it does.
	for piece in board.pieces:
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.WHITE:
			white_shield_king_alive = true
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.BLACK:
			black_shield_king_alive = true

func get_pos_under_mouse():
	var pos = get_global_mouse_position()
	pos.x = int(pos.x / 120)
	pos.y = int(pos.y / 120)
	return pos

func drop_piece():
	var is_shooting = false
	var is_jousting = false
	var piece_died = false
	var to_move = get_pos_under_mouse()
	var old_pos = selected_piece.board_position
	var piece_around
	var checker_captured = false
	var jumped
	var jumped_piece_location
	
	if valid_move(old_pos, to_move):
		# For valid move:
		# - if target has piece, then replace it
		var dest_piece = board.get_piece(to_move)
		#If piece is checker, delete the jumped piece
		if selected_piece.piece_type == Globals.PIECE_TYPES.CHECKER:
			jumped_piece_location = selected_piece.checker_capture_pos()
			if selected_piece.checker_capture_pos() != []:
			#	print("the current capture value is: ")
			#	print(jumped_piece_location)
				jumped = board.get_piece(Vector2(jumped_piece_location[0]))
				dest_piece = jumped
				#board.delete_piece(jumped)
				checker_captured = true
		
		# Delete only if the target piece is of different color
		if dest_piece != null and dest_piece.color != selected_piece.color:
			if dest_piece.piece_type == Globals.PIECE_TYPES.TROJAN_HORSE:
				dest_piece.trojan_spawn(dest_piece.color)
			if dest_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
				for position in dest_piece.bishop_explode_positions():
					spawn_explosion(position)
					piece_around = board.get_piece(position)
					if piece_around != null:
						board.delete_piece(piece_around)
				if selected_piece.piece_type != Globals.PIECE_TYPES.HORSE_ARCHER:
					board.delete_piece(selected_piece)
			if selected_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
				for position in dest_piece.bishop_explode_positions():
					spawn_explosion(position)
					piece_around = board.get_piece(position)
					if piece_around != null and piece_around.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
						board.delete_piece(piece_around)
						board.delete_piece(selected_piece)
						end_turn()
						return true
				for pos in dest_piece.bishop_explode_positions():
					spawn_explosion(position)
					piece_around = board.get_piece(pos)
					if piece_around != null:
						board.delete_piece(piece_around)
					board.delete_piece(selected_piece)
			if dest_piece.piece_type == Globals.PIECE_TYPES.TROJAN_HORSE:
				dest_piece.trojan_spawn(dest_piece.color)
			if dest_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
				for position in dest_piece.bishop_explode_positions():
					spawn_explosion(position)
					piece_around = board.get_piece(position)
					if piece_around != null:
						board.delete_piece(piece_around)
				if selected_piece.piece_type != Globals.PIECE_TYPES.HORSE_ARCHER:
					board.delete_piece(selected_piece)
			if dest_piece.piece_type == Globals.PIECE_TYPES.JOUST_BISHOP:
				piece_died = true
			board.delete_piece(dest_piece)
			selected_piece.move_position(selected_piece.board_position)
			if selected_piece.piece_type == Globals.PIECE_TYPES.HORSE_ARCHER:
				is_shooting = true
			if selected_piece.piece_type == Globals.PIECE_TYPES.JOUST_BISHOP:
				is_jousting = true
		if is_shooting == false:
			#print(selected_piece.board_position - to_move)
			selected_piece.move_position(to_move)
			if selected_piece.piece_type == Globals.PIECE_TYPES.STUN_KNIGHT:
				for space in selected_piece.get_stun_positions():
					var piece = board.get_piece(space)
					if piece != null:
						piece.stun_counter = 2
		if selected_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
			board.register_king(selected_piece.board_position, selected_piece.color)
			print("drop_piece registered king")
		if is_jousting:
			var joust_pos = to_move + joust_direction(old_pos, to_move)
			dest_piece = board.get_piece(joust_pos)
			board.delete_piece(dest_piece)
			if dest_piece != null and valid_move(to_move, joust_pos):
				selected_piece.move_position(joust_pos)
		if piece_died:
			board.delete_piece(selected_piece)
			
		# - change currnet status of active color
		if !checker_captured:
			end_turn()
		else:
			reset_timer()
			board.update_indicators()
		return true
	return false

func valid_move(from_pos, to_pos):
	var board_copy = board.clone()
	var src_piece = board_copy.get_piece(from_pos)
	var shield_king_position
	var shield_king
	
	# If we cannot move to threatend or moveable position
	if(
		to_pos not in src_piece.get_moveable_positions()
		and
		to_pos not in src_piece.get_threatened_positions()
	):
		return false
	
	if status == Globals.COLORS.WHITE && black_shield_king_alive:
		shield_king_position = board.black_king_pos
		shield_king = board_copy.get_piece(shield_king_position)
	elif status == Globals.COLORS.BLACK && white_shield_king_alive:
		shield_king_position = board.white_king_pos
		shield_king = board_copy.get_piece(shield_king_position)
	if src_piece.piece_type != Globals.PIECE_TYPES.EXPLODING_BISHOP && shield_king != null:
		for position in shield_king.shield_king_protect_positions():
			print(position)
			if board_copy.get_piece(position) != null && position == to_pos:
				return false
	
	var dest_piece = board.get_piece(to_pos)
	if dest_piece != null and (board.piece_is_protected(dest_piece) or dest_piece.piece_type == Globals.PIECE_TYPES.DUCK):
		return false
			
	
	var dst_piece = board_copy.get_piece(to_pos)
	if dst_piece != null:
		board_copy.delete_piece(dst_piece)
	src_piece.move_position(to_pos)
	
	
	
	return true

# Determine the square the jousting bishop should go
func joust_direction(old_pos, to_move):
	var pos = Vector2(0, 0)
	
	if old_pos.x < to_move.x:
		pos.x = 1
	else:
		pos.x = -1
	
	if old_pos.y > to_move.x:
		pos.y = -1
	else:
		pos.y = 1
	
	print(pos)
	return pos

func get_valid_moves():
	# Get possible moves for current player
	var valid_moves = []
#	var shield_king_position
#	var shield_king
	
	for piece in board.pieces:
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


func player2_move():
	var piece_died = false
	
	# Make a move when player2 is AI, else default controller is with user itself
	if player2_type == Globals.PLAYER_2_TYPE.AI:
		var valid_moves = get_valid_moves()
		if len(valid_moves) == 0:
			set_win(Globals.PLAYER.ONE)
			return
		var move = valid_moves.pick_random()
		var piece = move[0]
		var pos = move[1]
		var dest_piece = board.get_piece(pos)
		# Delete only if the target piece is found
		if dest_piece != null:
			if dest_piece.piece_type == Globals.PIECE_TYPES.JOUST_BISHOP:
				piece_died = true
			board.delete_piece(dest_piece)
		piece.move_position(pos)
		if piece_died:
			board.delete_piece(piece)
		end_turn()
		evaluate_end_game()
		
func move_from_timeout(otherPlayer : Globals.PLAYER):
	var piece_died = false
	
	var valid_moves = get_valid_moves()
	if len(valid_moves) == 0:
		set_win(otherPlayer)
		return
	var move = valid_moves.pick_random()
	var piece = move[0]
	var pos = move[1]
	var dest_piece = board.get_piece(pos)
	
	if dest_piece != null:
		if dest_piece.piece_type == Globals.PIECE_TYPES.JOUST_BISHOP:
			piece_died = true
		board.delete_piece(dest_piece)
	piece.move_position(pos)
	if piece_died:
		board.delete_piece(piece)
	end_turn()
	evaluate_end_game()
			

func evaluate_end_game():
	# Check whether the current user can make any legal move
	var moves = get_valid_moves()
	if len(moves) == 0:
		game_over = true
		move_timer.stop()
		set_win(Globals.PLAYER.TWO if status == player_color else Globals.PLAYER.ONE)
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
		move_timer.stop()
		set_win(Globals.PLAYER.TWO if status == player_color else Globals.PLAYER.ONE)
		return true
			
	return false

func set_win(who: Globals.PLAYER):
	game_over = true
	if who == Globals.PLAYER.ONE:
		win_label.text = "Player One Won"
	else:
		win_label.text = "Player Two Won"
	win_label.show()
	ui_control.show()
	
func spawn_explosion(pos : Vector2):
	var actual_pos = Vector2(pos.x * 120 + 60, pos.y * 120 + 60)
	var explosion = explosionScene.instantiate()
	explosion.position = actual_pos
	add_child(explosion)


func _on_button_pressed():
	get_tree().reload_current_scene()

func end_turn():
	for piece in board.pieces:
		if piece.stun_counter > 0:
			piece.stun_counter -= 1
	status = Globals.COLORS.BLACK if status == Globals.COLORS.WHITE else Globals.COLORS.WHITE
	
	reset_timer()
	board.update_indicators()
	
func _on_board_setup_complete() -> void:
	setup_complete = true
	setup_ui.hide()
	timer_bar.show()
	status = Globals.COLORS.WHITE
	print("init_pieces call")
	init_pieces()
	reset_timer()
	board.update_indicators()


func _on_board_set_status(color: Variant) -> void:
	status = color
	print(color)


func _on_opponent_ui_ai_op() -> void:
	player2_type = Globals.PLAYER_2_TYPE.AI
	print("ai set")


func _on_opponent_ui_human_op() -> void:
	player2_type = Globals.PLAYER_2_TYPE.HUMAN


func _on_board_spawn_ai() -> void:
	if player2_type == Globals.PLAYER_2_TYPE.AI:
		print("emit init_ai")
		emit_signal("init_ai")
	else:
		print("fail")

func init_pieces():
	for piece in board.pieces:
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
			board.register_king(piece.board_position, piece.color)



# Timer code

func _on_move_timer_timeout() -> void:
	print("ran out of time")
	
	var player
	if status == Globals.COLORS.WHITE:
		player = Globals.PLAYER.ONE
	else:
		player = Globals.PLAYER.TWO
	move_from_timeout(player)

func _process(delta):
	if move_timer.is_stopped():
		return
	
	time_remaining -= delta
	#timer_label.text = str(max(0, int(time_remaining)))
	timer_bar.value = time_remaining
	
func reset_timer():
	time_remaining = move_time
	#timer_label.text = str(int(time_remaining))
	timer_bar.value = move_time
	move_timer.start(move_time)
