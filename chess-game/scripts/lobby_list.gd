class_name LobbyList
extends Control

signal join_button_pressed(index : int)

const LOBBY_LIST_ENTRY = preload("uid://beekdbp76itqm")

const WHITE_TEXTURE = preload("res://Assets/LobbyMenuImages/WhiteShieldKing.png")
const BLACK_TEXTURE = preload("res://Assets/LobbyMenuImages/BlackShieldKing.png")

@onready var v_box_container: VBoxContainer = $HBoxContainer/ScrollContainer/VBoxContainer
@onready var chess_background: Control = $HBoxContainer/chess_background
@onready var color_rect: TextureRect = $HBoxContainer/chess_background/Color_Rect
@onready var map_rect: TextureRect = $HBoxContainer/chess_background/Map_Rect
@onready var description_label: Label = $HBoxContainer/chess_background/DescriptionLabel
@onready var details_label: Label = $HBoxContainer/chess_background/DetailsLabel
@onready var join_button: DynamicButton = $HBoxContainer/chess_background/Join_Button
@onready var title_label: Label = $HBoxContainer/chess_background/TitleLabel
@onready var number_label: Label = $HBoxContainer/chess_background/NumberLabel

var current_entry_index : int = -1

var current_entry : LobbyListEntry

func _ready() -> void:
	join_button.button_triggered.connect(_on_join_button_pressed)
	join_button.disable()
	
	color_rect.hide()
	map_rect.hide()
	description_label.hide()
	details_label.hide()

func add_list_entry(entry : LobbyListEntry):
	entry.pressed.connect(button_pressed.bind(entry))
	v_box_container.add_child(entry)

func clear():
	for it in v_box_container.get_children():
		it.queue_free()

func button_pressed(entry : LobbyListEntry):
	title_label.text = entry.title
	details_label.text = entry.details
	description_label.text = entry.description
	number_label.text = "#" + str(entry.number)
	current_entry_index = entry.number
	
	current_entry = entry
	set_textures()
	
	join_button.enable()
	color_rect.show()
	map_rect.show()
	description_label.show()
	details_label.show()

func _on_join_button_pressed() -> void:
	if current_entry_index == -1:
		return
	join_button_pressed.emit(current_entry_index)

func set_textures():
	match current_entry.host_color:
		Globals.COLORS.WHITE:
			color_rect.texture = BLACK_TEXTURE
		Globals.COLORS.BLACK:
			color_rect.texture = WHITE_TEXTURE
