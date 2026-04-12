extends Control

@onready var ip_input: LineEdit = $VBoxContainer/IP_Input
@onready var host_button: Button = $VBoxContainer/Host_Button
@onready var join_button: Button = $VBoxContainer/Join_Button
@onready var status: Label = $VBoxContainer/Status
@onready var start_button: Button = $VBoxContainer/Start_Button

var players_ready : int = 0

func _ready() -> void:
	start_button.hide()
	
	Network.player_connected.connect(on_player_connected)
	Network.player_disconnected.connect(on_player_disconnected)
	Network.connection_failed.connect(on_connection_failed)
	Network.server_disconnected.connect(on_server_disconnected)

func _on_host_button_pressed() -> void:
	Network.host_game()
	status.text = "Waiting for opponent..."
	host_button.disabled = true
	join_button.disabled = true
	ip_input.editable = false
	players_ready = 1

func _on_join_button_pressed() -> void:
	var address = ip_input.text.strip_edges()
	if address == "":
		address = "127.0.0.1"
	Network.join_game(address)
	status.text = "Connecting..."
	host_button.disabled = true
	join_button.disabled = true
	ip_input.editable = false

func on_player_connected(_peer_id : int):
	players_ready += 1
	status.text = "Player connected (%d/2)" % players_ready
	if players_ready >= 2:
		if multiplayer.is_server():
			start_button.show()
			status.text = "Both players are ready"

func on_player_disconnected(_peer_id : int):
	players_ready -= 1
	status.text = "Opponent disconnected"
	start_button.hide()

func on_connection_failed():
	status.text = "Connection failed. Try again"
	reset_ui()

func on_server_disconnected():
	status.text = "Host disconnected"
	reset_ui()

func _on_start_button_pressed() -> void:
	Network.assign_colors()
	load_game.rpc()

@rpc("authority", "call_local", "reliable")
func load_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func reset_ui():
	host_button.disabled = false
	join_button.disabled = false
	ip_input.editable = true
	players_ready = 0
