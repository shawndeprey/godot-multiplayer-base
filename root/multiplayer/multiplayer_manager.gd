class_name MultiplayerManager extends Node

signal ip_data_gathered
signal client_connection_fail
signal client_connection_success
signal host_game_fail

@export var port: int = 4242
@export var max_players: int = 4
var is_hosting: bool = false
var peer: ENetMultiplayerPeer
var ip_data: Dictionary = {
	localhost =  "127.0.0.1",
	lan = "",
	public = "Fetching..."
}

# Start a multiplayer game as the host
func host_game() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_players)
	if error != OK:
		print("[MultiplayerManager] Host Failure: Please check your connection and try again.")
		is_hosting = false
		host_game_fail.emit()
		print("[MultiplayerManager] Done setting up host game...")
		return
	multiplayer.multiplayer_peer = peer
	if !multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if !multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("[MultiplayerManager] Hosting game on port %d" % port)
	is_hosting = true
	
	# Level loading like this within the MP manager will likely need to be moved in the future
	# to a proper level manager or some other wrapper. It's not the MP manager's responsibility.
	print("[MultiplayerManager] Done setting up host game...")

# Join a multiplayer game as a client
func join_game(ip: String):
	if !multiplayer.connection_failed.is_connected(_on_connected_fail):
		multiplayer.connection_failed.connect(_on_connected_fail)
	if !multiplayer.connected_to_server.is_connected(_on_connected_ok):
		multiplayer.connected_to_server.connect(_on_connected_ok)
	if !multiplayer.server_disconnected.is_connected(start_offline_mode):
		multiplayer.server_disconnected.connect(start_offline_mode)

	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		print("[MultiplayerManager] Failed to join game!")
		return
	multiplayer.multiplayer_peer = peer
	is_hosting = false
	print("[MultiplayerManager] Joining game at %s:%d" % [ip, port])

func _on_connected_fail() -> void:
	start_offline_mode(false)
	print("[MultiplayerManager] Client Failure: Failed to connect to host. Please check your connection and try again.")
	client_connection_fail.emit()

func _on_connected_ok() -> void:
	#print("[MultiplayerManager] Client connection successful")
	client_connection_success.emit()

# Called when a new player connects (Only runs on the host)
func _on_peer_connected(peer_id: int):
	print("[MultiplayerManager] Player %d connected" % peer_id)
	if multiplayer.is_server():
		var player_instance: Player = _spawn_network_player(peer_id)
		player_instance.connected_to_server.rpc_id(peer_id)

# Called when a player disconnects (Only runs on the host)
func _on_peer_disconnected(peer_id: int):
	print("[MultiplayerManager] Player %d disconnected" % peer_id)
	if multiplayer.is_server():
		_remove_player(peer_id)

func close_peer_and_reboot():
	if multiplayer.is_server():
		print("[MultiplayerManager] Host is shutting down the server.")
		for peer_id in multiplayer.get_peers():
			multiplayer.disconnect_peer(peer_id)
	start_offline_mode(true)

func start_offline_mode(reboot_game: bool = true) -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	if reboot_game:
		Game.root().reset_game()

func _spawn_local_player():
	if multiplayer.get_unique_id() == 1:
		#print("[MultiplayerManager] Spawning single-player mode player.")
		var local_player: Player = _spawn_network_player(multiplayer.get_unique_id())
		local_player.connected_to_server()

# Spawns a player using the MultiplayerSpawner (Server Only)
func _spawn_network_player(peer_id: int) -> Player:
	return _spawn_player_instance(peer_id)

# Called by MultiplayerSpawner to actually instantiate the player
func _spawn_player_instance(peer_id: int) -> Player:
	if !multiplayer.is_server(): return
	print("[MultiplayerManager] Instantiating player for peer %d" % peer_id)
	var player_scene = load("res://root/entities/player/player.tscn")
	var player_instance = player_scene.instantiate()
	player_instance.peer_id = peer_id
	player_instance.name = str(peer_id)
	player_instance.set_multiplayer_authority(peer_id)
	Game.world().server_spawn_entity(player_instance)
	return player_instance

# Removes a player from the game (Server Only)
func _remove_player(peer_id: int):
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.get_multiplayer_authority() == peer_id:
			print("[MultiplayerManager] Removing player %d" % peer_id)
			player.queue_free()

func get_ip_addresses() -> void:
	ip_data.localhost = "localhost"

	# Get Local Network (LAN) IP
	var local_ips = IP.get_local_addresses()
	for ip in local_ips:
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172.16."):
			ip_data.lan = ip
			break

	# Fetch Public IP Without Adding to Scene Tree
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)
	http.request_completed.connect(grab_public_ip)
	http.request("https://api.ipify.org")

func grab_public_ip(_result, _response_code, _headers, _body):
	ip_data.public = _body.get_string_from_utf8()
	ip_data_gathered.emit()
	# If the player is actively hosting, display message
	if is_hosting:
		print("[MultiplayerManager] Hosting Game - IP: " + ip_data.public + " Port: 4242")
