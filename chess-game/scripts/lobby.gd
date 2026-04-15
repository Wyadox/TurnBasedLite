extends Control

@onready var host_button: Button = $VBoxContainer/Host_Button
@onready var join_button: Button = $VBoxContainer/Join_Button
@onready var status: Label = $VBoxContainer/Status
@onready var start_button: Button = $VBoxContainer/Start_Button
@onready var lobby_list: LobbyList = $VBoxContainer/HBoxContainer/lobby_list
@onready var host_options_menu: Control = $VBoxContainer/HBoxContainer/host_options_menu

const LOBBY_LIST_ENTRY = preload("uid://beekdbp76itqm")

var players_ready : int = 0
var discovered_ip_addresses : Array = []

var current_map : int = 0
var difficulty : Globals.DIFFICULTY = Globals.DIFFICULTY.EASY

var lobby_game_info : Dictionary = {}

func _ready() -> void:
	start_button.hide()
	lobby_list.hide()
	host_options_menu.hide()
	
	Network.player_connected.connect(on_player_connected)
	Network.player_disconnected.connect(on_player_disconnected)
	Network.connection_failed.connect(on_connection_failed)
	Network.server_disconnected.connect(on_server_disconnected)
	Network.host_discovered.connect(on_host_discovered)
	
	lobby_list.join_button_pressed.connect(on_join_match_pressed)
	
	host_options_menu.host_button_pressed.connect(intialize_host)

func _on_host_button_pressed() -> void:
	host_options_menu.show()
	lobby_list.hide()
	
	host_button.disabled = true
	join_button.disabled = true
	

func intialize_host() -> void:
	host_options_menu.hide()
	
	Network.game_info["difficulty"] = host_options_menu.get_difficulty()
	Network.game_info["map"] = host_options_menu.get_map()
	Network.game_info["color"] = host_options_menu.get_color()
	
	Network.host_color = Network.game_info["color"]
	print("host_color set: ", Network.game_info["color"])
	if Network.host_color == Globals.COLORS.WHITE:
		Network.client_color = Globals.COLORS.BLACK
	else:
		Network.client_color = Globals.COLORS.WHITE
	
	lobby_game_info = Network.game_info
	
	Network.host_game()
	status.text = "Waiting for opponent..."
	players_ready = 1

func _on_join_button_pressed() -> void:
	Network.start_listening()
	status.text = "Looking for matches..."
	host_button.disabled = true
	join_button.disabled = true
	lobby_list.clear()
	discovered_ip_addresses.clear()
	lobby_list.show()

func on_host_discovered(ip_address : String, data : Dictionary):
	if ip_address in discovered_ip_addresses:
		return
	
	discovered_ip_addresses.append(ip_address)
	var entry = LOBBY_LIST_ENTRY.instantiate()
	entry.number = discovered_ip_addresses.size() - 1
	if entry.number % 2 == 0:
		entry.background_color = Color(0.8, 0.6, 0.4)
	else:
		entry.background_color = Color(0.4, 0.3, 0.2)
	print("hello", data["host_color"])
	entry.title = "Play against " + Globals.COLORS.find_key(int(data["host_color"]))
	entry.details = "Playing on " + Globals.DIFFICULTY.find_key(int(data["difficulty"])) + " difficulty"
	entry.description = "HELLO"
	lobby_list.add_list_entry(entry)
	entry.set_textures(data["difficulty"], data["host_color"] as Globals.DIFFICULTY, data["map"])
	lobby_game_info = data
	status.text = "Found %d game(s) - select one" % discovered_ip_addresses.size()

func on_player_connected(_peer_id : int):
	players_ready += 1
	status.text = "Player connected (%d/2)" % players_ready
	if players_ready >= 2:
		if multiplayer.is_server():
			Network.stop_broadcasting()
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
	Network.stop_listening()
	
	const GAME_SCENE = preload("res://scenes/game.tscn")
	var game_scene = GAME_SCENE.instantiate()
	
	game_scene.player2_type = Globals.PLAYER_2_TYPE.NETWORK
	game_scene.difficulty = lobby_game_info["difficulty"]
	game_scene.current_map = lobby_game_info["map"]
	game_scene.online_game = true
	
	var scene_tree = get_tree()
	scene_tree.current_scene.queue_free()
	scene_tree.root.add_child(game_scene)
	scene_tree.current_scene = game_scene
	SignalBus.emit_signal("change_map", lobby_game_info["map"])

func reset_ui():
	host_button.disabled = false
	join_button.disabled = false
	lobby_list.hide()
	lobby_list.clear()
	discovered_ip_addresses.clear()
	players_ready = 0

func on_join_match_pressed(index: int) -> void:
	var ip_address = discovered_ip_addresses[index]
	Network.join_game(ip_address)
	status.text = "Connecting..."
	lobby_list.hide()
