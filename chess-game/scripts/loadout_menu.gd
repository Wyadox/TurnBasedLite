extends Control

const BOARD = preload("res://scenes/board.tscn")
var board_scene

@onready var setup_scene = $SetupPhaseUI
const SETUP_SCENE = preload("res://scenes/setup_phase_ui.tscn")

@onready var save_button: DynamicButton = $HBoxContainer/Save_Button
@onready var load_button: DynamicButton = $HBoxContainer/Load_Button
@onready var exit_button: DynamicButton = $Exit_Button
@onready var clear_button: DynamicButton = $Clear_Button

var selected_loadout = 0

var is_dragging : bool = false
var piece_died : bool = false

var selected_piece
var selected_square = null
var previous_position = Vector2(0, 0)

# ISSUE 4/1 2 AM, Loading loadout doesn't work since board reposition

func _ready() -> void:
	board_scene = BOARD.instantiate()
	
	board_scene.global_position.x += 550
	board_scene.global_position.y += 625
	board_scene.is_loadout_board = true
	
	add_child(board_scene)
	
	SignalBus.loadout_button.connect(loadout_button_pressed)
	SignalBus.show_notification.connect(show_notification)
	
	save_button.button_triggered.connect(_on_button_save_pressed)
	load_button.button_triggered.connect(_on_button_load_pressed)
	clear_button.button_triggered.connect(_on_button_clear_pressed)
	exit_button.button_triggered.connect(_on_button_exit_pressed)
	

func _input(event):
	if Input.is_action_just_pressed("left_click"):
		selected_square = get_square_under_mouse()
		selected_piece = board_scene.get_piece(selected_square)
			
		if selected_piece == null:
			if is_within_bounds(selected_square) and board_scene.num_pieces() < Globals.PIECES_PER_SIDE:
				SignalBus.emit_signal("selected_square", selected_square)
			#else:
				#SignalBus.emit_signal("selected_square", Vector2(-1, -1))
			return
		else:
			SignalBus.emit_signal("selected_square", Vector2(-1, -1))
			is_dragging = true
			previous_position = selected_piece.position
			selected_piece.z_index = 100
			selected_piece.play_animation("sway")
	elif event is InputEventMouseMotion and is_dragging:
		var piece_mouse_pos = get_global_mouse_position() - board_scene.global_position
		selected_piece.position = piece_mouse_pos
	elif Input.is_action_just_released("left_click") and is_dragging:
		if !selected_piece:
			return
		
		selected_piece.play_animation("idle")
		selected_piece.z_index = 0
		is_dragging = false
		
		var is_valid_move = drop_piece()
		
		if piece_died:
			ExplodingBishop.spawn_explosion_literal(selected_piece.position + board_scene.global_position)
			
			setup_scene._on_board_refund_piece(selected_piece.piece_type)
			board_scene.delete_piece(selected_piece, true)
			piece_died = false
		
		if !is_valid_move:
			selected_piece.position = previous_position
		
		selected_piece = null
		selected_square = null

func get_square_under_mouse():
	var square = get_global_mouse_position() - board_scene.global_position
	
	if square.x < 0 or square.y < 0:
		return Vector2(-1, -1)
	
	square.x = int(square.x / 120)
	square.y = int(square.y / 120)
	return square

func drop_piece() -> bool:
	var drop_square = get_square_under_mouse()
	if !is_within_bounds(drop_square):
		if drop_square.x > 7 and drop_square.y > 0:
			piece_died = true
		return false
	
	for piece in board_scene.pieces:
		if piece != selected_piece and piece.board_position == drop_square:
			piece.move_position(selected_piece.board_position, true)
			selected_piece.move_position(drop_square, true)
			board_scene.play_sound("capture")
			return true
	
	selected_piece.move_position(drop_square, true)
	board_scene.play_sound("move")
	return true

func is_within_bounds(pos : Vector2):
	return pos.x < board_scene.BOARD_WIDTH and pos.x > -1 and pos.y > -1 and pos.y < 2

func _on_button_clear_pressed() -> void:
	board_scene.wipe_pieces(true, true)
	setup_scene.queue_free()
	setup_scene = SETUP_SCENE.instantiate()
	setup_scene.global_position = Vector2(103.0, -5)
	setup_scene.visible = false
	add_child(setup_scene)
	show_notification("Board Cleared")


func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_save_pressed() -> void:
	var save_string = ""
	
	if board_scene.num_pieces() != Globals.PIECES_PER_SIDE:
		show_notification("YOU MUST PLACE " + str(Globals.PIECES_PER_SIDE) + " PIECES")
		return
		
	for piece in board_scene.pieces:
		save_string += str(piece.piece_type) + ":" + str(convert_position(piece.board_position)) + "_"
	
	if selected_loadout == 1:
		LoadoutSaves.loadouts_to_save.loadout1 = save_string
	elif selected_loadout == 2:
		LoadoutSaves.loadouts_to_save.loadout2 = save_string
	else:
		LoadoutSaves.loadouts_to_save.loadout3 = save_string
	LoadoutSaves._save()
	show_notification("Loadout Saved")

func convert_position(pos : Vector2):
	var new_pos = Vector2(pos.x - 1, pos.y + 5)
	return new_pos
	
func loadout_button_pressed(loadout):
	selected_loadout = loadout

func _on_button_load_pressed() -> void:
	_on_button_clear_pressed()
	
	if selected_loadout == 0:
		return
	
	var spawn_string : String
	if selected_loadout == 1:
		spawn_string = LoadoutSaves.loadouts_to_save.loadout1
	elif selected_loadout == 2:
		spawn_string = LoadoutSaves.loadouts_to_save.loadout2
	else:
		spawn_string = LoadoutSaves.loadouts_to_save.loadout3
	print("Spawn String: ", spawn_string)
	spawn_pieces(spawn_string)
	show_notification("Loadout Loaded")
	
# AI LOADOUTS

# EASY
# 

# NORMAL
# Pawns - 7:(2.0, 6.0)_9:(1.0, 6.0)_13:(2.0, 5.0)_21:(3.0, 6.0)_11:(-1.0, 5.0)_14:(5.0, 5.0)_17:(-1.0, 6.0)_


# HARD
# Bubble - 7:(2.0, 6.0)_8:(2.0, 5.0)_11:(-1.0, 6.0)_20:(1.0, 5.0)_25:(3.0, 6.0)_4:(3.0, 5.0)_22:(1.0, 6.0)_
# Infector Trap - 21:(2.0, 6.0)_16:(3.0, 5.0)_7:(3.0, 6.0)_22:(2.0, 5.0)_13:(-1.0, 6.0)_6:(-1.0, 5.0)_14:(1.0, 5.0)_
# Wizard - 25:(2.0, 6.0)_4:(-1.0, 5.0)_14:(5.0, 5.0)_16:(2.0, 5.0)_13:(0.0, 5.0)_5:(4.0, 5.0)_22:(1.0, 5.0)_

	
func spawn_pieces(pieces : String):
	var spawn_array = pieces.split("_", false)
	for spawn in spawn_array:
		var spawn_split = spawn.split(":")
		var coord_split = spawn_split[1].split(",")
		board_scene.selected_pos = Vector2(int(coord_split[0]) + 1,int(coord_split[1]) - 5)
		setup_scene.valid_spawn(int(spawn_split[0]))
		board_scene._on_setup_phase_ui_spawn_piece(int(spawn_split[0]))

func show_notification(phrase : String):
	$notification.set_text(phrase)
