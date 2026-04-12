extends Node

const PORT = 7777
const MAX_PLAYERS = 2

signal player_connected(peer_id : int)
signal player_disconnected(peer_id : int)
signal server_disconnected()
signal connection_failed()

var my_color : Globals.COLORS = Globals.COLORS.WHITE
var opponent_id : int = -1

func _ready() -> void:
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)

func assign_colors():
	if multiplayer.is_server():
		my_color = Globals.COLORS.WHITE
		for peer in multiplayer.get_peers():
			opponent_id = peer
		set_client_color.rpc_id(opponent_id)

@rpc("authority", "reliable")
func set_client_color():
	my_color = Globals.COLORS.BLACK
	multiplayer.get_unique_id()

func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		push_error("Server creation failed : ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("NETWORK : Hosting on port ", PORT)

func join_game(address : String): 
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error != OK:
		push_error("Connection failed : ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("NETWORK : Connecting to ", address)

func disconnect_game():
	multiplayer.multiplayer_peer = null

func on_peer_connected(peer_id : int):
	print("NETWORK : Peer connected -- ", peer_id)
	player_connected.emit(peer_id)

func on_peer_disconnected(peer_id : int):
	print("NETWORK : Peer disconnected -- ", peer_id)
	player_disconnected.emit(peer_id)

func on_connected_to_server():
	print("NETWORK : Connected to server. My ID -- ", multiplayer.get_unique_id())
	player_connected.emit(multiplayer.get_unique_id())

func on_connection_failed():
	push_error("Connection failed")
	multiplayer.multiplayer_peer = null
	connection_failed.emit()

func on_server_disconnected():
	push_error("Server disconnected")
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
