extends Control

const BOARD = preload("res://scenes/board.tscn")
var board_scene

const X_OFFSET = 1
const Y_OFFSET = 3

@onready var setup_scene = $SetupPhaseUI
const SETUP_SCENE = preload("res://scenes/setup_phase_ui.tscn")

var selected_loadout = 1

func _ready() -> void:
	board_scene = BOARD.instantiate()
	board_scene.is_loadout_board = true
	add_child(board_scene)
	
	SignalBus.loadout_button.connect(loadout_button_pressed)
	

func _input(_event):
	if Input.is_action_just_pressed("left_click"):
		var pos = get_pos_under_mouse()
		var selected_piece = board_scene.get_piece(pos)
			
		if selected_piece == null:
			# REMEMBER THESE OFFSETS, it's very janky
			if pos.x < board_scene.BOARD_WIDTH + 1 and pos.x > 0 and pos.y < board_scene.BOARD_HEIGHT - 1 and pos.y > 3 and board_scene.num_pieces() < Globals.PIECES_PER_SIDE:
				SignalBus.emit_signal("selected_square", pos)
			else:
				print("no square was selected")
				print("failed position: ", pos)
				print("board total: ", board_scene.num_pieces())
			return
		print("not in setup phase")

func get_pos_under_mouse():
	var pos = get_global_mouse_position()
	pos.x = int(pos.x / 120)
	pos.y = int(pos.y / 120)
	return pos


func _on_button_clear_pressed() -> void:
	board_scene.wipe_pieces(true, true)
	setup_scene.queue_free()
	setup_scene = SETUP_SCENE.instantiate()
	setup_scene.global_position = Vector2(103.0, -5)
	add_child(setup_scene)


func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_save_pressed() -> void:
	var save_string = ""
	
	if board_scene.num_pieces() != Globals.PIECES_PER_SIDE:
		print("YOU MUST PLACE", Globals.PIECES_PER_SIDE, " PIECES")
		return
		
	for piece in board_scene.pieces:
		save_string += str(piece.piece_type) + ":" + str(convert_position(piece.board_position)) + "_"
	
	print("selected loadout: ", selected_loadout)
	if selected_loadout == 1:
		LoadoutSaves.loadouts_to_save.loadout1 = save_string
	elif selected_loadout == 2:
		LoadoutSaves.loadouts_to_save.loadout2 = save_string
	else:
		LoadoutSaves.loadouts_to_save.loadout3 = save_string
	LoadoutSaves._save()

func convert_position(pos : Vector2):
	var new_pos = Vector2(pos.x - 1, pos.y + 1)
	return str(new_pos.x) + "," + str(new_pos.y)
	
func loadout_button_pressed(loadout):
	selected_loadout = loadout
	print(loadout)

func _on_button_load_pressed() -> void:
	_on_button_clear_pressed()
	
	var spawn_string : String
	if selected_loadout == 1:
		spawn_string = LoadoutSaves.loadouts_to_save.loadout1
	elif selected_loadout == 2:
		spawn_string = LoadoutSaves.loadouts_to_save.loadout2
	else:
		spawn_string = LoadoutSaves.loadouts_to_save.loadout3
	spawn_pieces(spawn_string)
	
func spawn_pieces(pieces : String):
	var spawn_array = pieces.split("_", false)
	for spawn in spawn_array:
		var spawn_split = spawn.split(":")
		var coord_split = spawn_split[1].split(",")
		board_scene.selected_pos = Vector2(int(coord_split[0]) + 1,int(coord_split[1]) - 1)
		board_scene._on_setup_phase_ui_spawn_piece(int(spawn_split[0]))
