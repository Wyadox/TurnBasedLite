extends Control

const BOARD = preload("res://scenes/board.tscn")
var board_scene

@onready var setup_scene = $SetupPhaseUI
const SETUP_SCENE = preload("res://scenes/setup_phase_ui.tscn")

var selected_loadout = 0

func _ready() -> void:
	board_scene = BOARD.instantiate()
	
	board_scene.global_position.x += 550
	board_scene.global_position.y += 600
	board_scene.is_loadout_board = true
	
	add_child(board_scene)
	
	SignalBus.loadout_button.connect(loadout_button_pressed)
	SignalBus.show_notification.connect(show_notification)
	

func _input(_event):
	if Input.is_action_just_pressed("left_click"):
		var square = get_square_under_mouse()
		var selected_piece = board_scene.get_piece(square)
			
		if selected_piece == null:
			if square.x < board_scene.BOARD_WIDTH and square.x > -1 and square.y > -1 and square.y < 2 and board_scene.num_pieces() < Globals.PIECES_PER_SIDE:
				SignalBus.emit_signal("selected_square", square)
				print("pos: ", square)
			return
		else:
			setup_scene._on_board_refund_piece(selected_piece.piece_type)
			board_scene.delete_piece(selected_piece, true)

func get_square_under_mouse():
	var square = get_global_mouse_position() - board_scene.global_position
	square.x = int(square.x / 120)
	print("X From: ", square.x / 120)
	square.y = int(square.y / 120)
	print("Y From: ", square.y / 120)
	return square


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
	var new_pos = Vector2(pos.x, pos.y + 5)
	return new_pos
	#return str(new_pos.x) + "," + str(new_pos.y)
	
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
	spawn_pieces(spawn_string)
	show_notification("Loadout Loaded")
	
func spawn_pieces(pieces : String):
	var spawn_array = pieces.split("_", false)
	for spawn in spawn_array:
		var spawn_split = spawn.split(":")
		var coord_split = spawn_split[1].split(",")
		board_scene.selected_pos = Vector2(int(coord_split[0]) + 1,int(coord_split[1]))
		setup_scene.valid_spawn(int(spawn_split[0]))
		board_scene._on_setup_phase_ui_spawn_piece(int(spawn_split[0]))

func show_notification(phrase : String):
	$notification.set_text(phrase)
