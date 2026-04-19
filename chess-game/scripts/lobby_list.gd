class_name LobbyList
extends Control

signal join_button_pressed(index : int)

const LOBBY_LIST_ENTRY = preload("uid://beekdbp76itqm")

@onready var v_box_container: VBoxContainer = $HBoxContainer/ScrollContainer/VBoxContainer
@onready var chess_background: Control = $HBoxContainer/chess_background
@onready var title_label: Label = $HBoxContainer/chess_background/MarginContainer/VBoxContainer/TitleLabel
@onready var details_label: Label = $HBoxContainer/chess_background/MarginContainer/VBoxContainer/DetailsLabel
@onready var description_label: Label = $HBoxContainer/chess_background/MarginContainer/VBoxContainer/DescriptionLabel
@onready var number_label: Label = $HBoxContainer/chess_background/MarginContainer/NumberLabel
@onready var join_button: DynamicButton = $HBoxContainer/chess_background/MarginContainer/VBoxContainer/HBoxContainer/Join_Button

var current_entry_index : int = -1

func _ready() -> void:
	join_button.button_triggered.connect(_on_join_button_pressed)

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
	number_label.text = str(entry.number)
	current_entry_index = entry.number

func _on_join_button_pressed() -> void:
	if current_entry_index == -1:
		return
	join_button_pressed.emit(current_entry_index)
