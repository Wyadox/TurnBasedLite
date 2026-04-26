extends Node

const PORT = 7777
const MAX_PLAYERS = 2

signal player_connected(peer_id : int)
signal player_disconnected(peer_id : int)
signal server_disconnected()
signal connection_failed()

var my_color : Globals.COLORS = Globals.COLORS.WHITE
var opponent_id : int = -1

var host_color : Globals.COLORS = Globals.COLORS.WHITE
var client_color : Globals.COLORS = Globals.COLORS.BLACK

var display_name : String = ""

var game_info : Dictionary = {
	"color" : Globals.COLORS.WHITE,
	"map" : 1,
	"difficulty" : Globals.DIFFICULTY.EASY
}

func _ready() -> void:
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)

func assign_colors():
	if multiplayer.is_server():
		my_color = host_color
		for peer in multiplayer.get_peers():
			opponent_id = peer
		var opponent_color = Globals.COLORS.BLACK if host_color == Globals.COLORS.WHITE else Globals.COLORS.WHITE
		set_client_color.rpc_id(opponent_id, opponent_color, multiplayer.get_unique_id())

@rpc("authority", "reliable")
func set_client_color(color : Globals.COLORS, host_peer_id : int):
	my_color = color
	opponent_id = host_peer_id

func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		push_error("Server creation failed : ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("NETWORK : Hosting on port ", PORT)
	start_broadcasting()

func join_game(address : String): 
	stop_listening()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error != OK:
		push_error("Connection failed : ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("NETWORK : Connecting to ", address)

func disconnect_game():
	stop_broadcasting()
	stop_listening()
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

func network_print(message : String):
	print("[%d] %s" % [multiplayer.get_unique_id(), message])

# UDP Stuff for LAN Lobby

signal host_discovered(ip_address : String, data : Dictionary)
signal host_lost(ip_address : String)

const BROADCAST_PORT = 7778
const BROADCAST_INTERVAL = 1.0
const GAME_IDENTIFIER = "CHAOS_CHESS_V1"

var udp_server : UDPServer
var broadcast_socket : PacketPeerUDP
var broadcast_timer : float = 0.0
var discovered_hosts : Dictionary = {}

func start_broadcasting():
	broadcast_socket = PacketPeerUDP.new()
	broadcast_socket.set_broadcast_enabled(true)
	broadcast_socket.bind(0)

func stop_broadcasting():
	if broadcast_socket:
		broadcast_socket.close()
		broadcast_socket = null

func start_listening():
	udp_server = UDPServer.new()
	udp_server.listen(BROADCAST_PORT)

func stop_listening():
	if udp_server:
		udp_server.stop()
		udp_server = null
	
	discovered_hosts.clear()

func _process(delta: float) -> void:
	# Host
	if broadcast_socket: 
		broadcast_timer += delta
		if broadcast_timer >= BROADCAST_INTERVAL:
			broadcast_timer = 0.0
			send_broadcast()
	
	# Client
	if udp_server:
		udp_server.poll()
		while udp_server.is_connection_available():
			var peer = udp_server.take_connection()
			var packet = peer.get_packet()
			handle_broadcast(packet, peer.get_packet_ip())

func send_broadcast():
	var data = {
		"id" : GAME_IDENTIFIER,
		"name" : SettingsManager.get_settings().display_name,
		"port" : PORT,
		"host_color" : game_info["color"],
		"difficulty" : game_info["difficulty"],
		"map" : game_info["map"]
	}
	var json = JSON.stringify(data)
	broadcast_socket.set_dest_address("255.255.255.255", BROADCAST_PORT)
	broadcast_socket.put_packet(json.to_utf8_buffer())

func handle_broadcast(packet : PackedByteArray, from_ip_address : String):
	var json = JSON.new()
	var result = json.parse(packet.get_string_from_utf8())
	if result != OK:
		return
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return
	if data.get("id") != GAME_IDENTIFIER:
		return
	
	discovered_hosts[from_ip_address] = data
	host_discovered.emit(from_ip_address, data)
