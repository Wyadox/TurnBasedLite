extends Control

const BOARD = preload("res://scripts/board.gd")

func _ready() -> void:
	draw_board()
	

func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func draw_board():
	for x in range(BOARD.BOARD_WIDTH):
		for y in range(2):
			draw_cell(x, y)
			
func draw_cell(x, y):
	var rect = ColorRect.new()
	rect.color = Color(0.8, 0.6, 0.4) if (x + y) % 2 == 0 else Color(0.4, 0.3, 0.2)
	rect.size = Vector2(BOARD.CELL_SIZE, BOARD.CELL_SIZE)
	rect.position = Vector2(
		x * BOARD.CELL_SIZE,
		y * BOARD.CELL_SIZE
	)
	rect.z_index = -100
	add_child(rect)
