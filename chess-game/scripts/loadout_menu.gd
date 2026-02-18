extends Control

const BOARD = preload("res://scenes/board.tscn")
var board_scene

const X_OFFSET = 1
const Y_OFFSET = 3

@onready var setup_scene = $SetupPhaseUI
const SETUP_SCENE = preload("res://scenes/setup_phase_ui.tscn")

@onready var loadout_slots_scene = $loadoutSlots

const PIECE_LIMIT = 7

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
			if pos.x < board_scene.BOARD_WIDTH + 1 and pos.x > 0 and pos.y < board_scene.BOARD_HEIGHT - 1 and pos.y > 3 and board_scene.num_pieces() < PIECE_LIMIT:
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
	board_scene.wipe_pieces()
	setup_scene.queue_free()
	setup_scene = SETUP_SCENE.instantiate()
	setup_scene.global_position = Vector2(103.0, -5)
	add_child(setup_scene)


func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_save_pressed() -> void:
	var save_string = ""
	for piece in board_scene.pieces:
		save_string += str(piece.piece_type) + ":" + str(convert_position(piece.board_position)) + "_"
		
	if selected_loadout == 1:
		loadout_slots_scene.slot1.SAVE_STRING = save_string
	print(save_string)

func convert_position(pos : Vector2):
	return Vector2(pos.x - 1, pos.y + 1)
	
func loadout_button_pressed(loadout):
	selected_loadout = loadout
	print(loadout)


func _on_button_load_pressed() -> void:
	if selected_loadout == 1:
		spawn_pieces(loadout_slots_scene.slot1.SAVE_STRING)
	
func spawn_pieces(pieces : String):
	print(pieces)
