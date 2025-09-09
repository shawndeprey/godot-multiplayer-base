class_name World extends Node2D

@export var layer_map: Dictionary = {1: null, 2: null, 3: null, 4: null}

func reset_world() -> void:
	clear_entities()
	clear_levels()

func reset_world_and_players() -> void:
	clear_entities()
	clear_levels()
	clear_players()

func clear_entities() -> void:
	for e in get_tree().get_nodes_in_group("entities"):
		if e is Player: continue
		e.queue_free()

func clear_levels() -> void:
	for l in get_tree().get_nodes_in_group("levels"):
		l.queue_free()
	layer_map = {1: null, 2: null, 3: null, 4: null}

func clear_players() -> void:
	for p in get_tree().get_nodes_in_group("players"):
		p.queue_free()

func client_layer() -> int:
	var p: Player = get_authority_player()
	return 0 if p == null else p.layer

func get_peers_in_layer(layer: int = client_layer()) -> Array[Player]:
	var players: Array[Player]
	var player: Player = get_authority_player()
	for p in get_tree().get_nodes_in_group("players"):
		if p.name == player.name: continue # Skip the self player, only get peers
		if p.layer == layer: players.append(p)
	return players

#func client_level() -> Level:
	#var current_client_layer: int = client_layer()
	#for l in get_tree().get_nodes_in_group("levels"):
		#if l.layer == current_client_layer: return l
	#return null

func client_level_path() -> String:
	return layer_map[client_layer()]

func leave_background_levels(_p: Player) -> void:
	var current_client_layer: int = client_layer()
	for l in get_tree().get_nodes_in_group("levels"):
		if l.layer != current_client_layer: l.leave_level(_p)

func client_update_layer_visibilities(_p: Player) -> void:
	#print("[WORLD] ", multiplayer.get_unique_id(), " updating layer visibilities to layer ", _p.layer)
	var layer_id = _p.layer
	for e in get_tree().get_nodes_in_group("entities"):
		e.match_layer(layer_id)
	for l in get_tree().get_nodes_in_group("levels"):
		l.visible = l.layer == layer_id
	for a in get_tree().get_nodes_in_group("atmosphere"):
		a.visible = a.get_owner().layer == layer_id

func close_empty_layers() -> void:
	await get_tree().create_timer(1).timeout
	var active_layers: Array[int] = []
	for p in get_tree().get_nodes_in_group("players"):
		if !active_layers.has(p.layer): active_layers.append(p.layer)
	for layer_id in layer_map.keys():
		if layer_map[layer_id] != null and !active_layers.has(layer_id):
			free_level(layer_id, layer_map[layer_id]) 

@rpc("any_peer", "reliable")
func request_level_load(level_path: String):
	# Handles either loading the level if is server, or calling off to the server to request a level
	if multiplayer.is_server():
		print("[GAME] ", multiplayer.get_remote_sender_id(), " requested level load for ", level_path)
		handle_level_load_request(multiplayer.get_remote_sender_id(), level_path)
	else:
		rpc_id(1, "request_level_load", level_path)

func handle_level_load_request(peer_id: int, level_path: String) -> void:
	var layer_id = get_level_layer(level_path)
	#print("[GAME] Handle level load request for ", peer_id, " for level ", level_path, " which is on layer ", layer_id)
	if !is_level_loaded(level_path): load_level(layer_id, level_path)
	if peer_id == 0: get_authority_player().join_layer(layer_id)
	else: rpc_id(peer_id, "tell_client_level_loaded", layer_id, level_path)

func load_level(layer_id: int, level_path: String) -> void:
	var level_instance = load(level_path).instantiate()
	level_instance.layer = layer_id
	Game.levels().add_child(level_instance)
	layer_map[layer_id] = level_path

func free_level(layer_id: int, level_path: String) -> void:
	#print("[WORLD] ", multiplayer.get_unique_id(), " FREEING level ", level_path, " on layer ", layer_id)
	var cleared_level: bool = false
	for level in Game.levels().get_children():
		if level.scene_file_path == level_path:
			level.queue_free()
			cleared_level = true
	if cleared_level:
		for e in get_tree().get_nodes_in_group("entities"):
			if e is Player: continue
			if e.layer == layer_id:
				e.queue_free() 
	layer_map[layer_id] = null

@rpc("any_peer", "reliable")
func tell_client_level_loaded(layer_id: int, level_path: String):
	#print("[GAME] Tell ", multiplayer.get_unique_id(), " of layer ", layer_id, " for level ", level_path)
	for level in Game.levels().get_children():
		level.queue_free()
	load_level(layer_id, level_path)
	get_authority_player().join_layer(layer_id)

func get_level_layer(level_path: String) -> int:
	# Gets an always unique layer_id for level paths
	if layer_map[1] == level_path: return 1
	if layer_map[2] == level_path: return 2
	if layer_map[3] == level_path: return 3
	if layer_map[4] == level_path: return 4
	# Find new layer to add level
	if layer_map[1] == null: return 1
	if layer_map[2] == null: return 2
	if layer_map[3] == null: return 3
	if layer_map[4] == null: return 4
	return 0

func is_level_loaded(level_path: String) -> bool:
	if layer_map[1] == level_path: return true
	if layer_map[2] == level_path: return true
	if layer_map[3] == level_path: return true
	if layer_map[4] == level_path: return true
	return false

func spawn_projectile(e, deferred = false) -> void:
	if deferred:
		Game.projectiles().call_deferred("add_child", e, true)
	else:
		Game.projectiles().add_child(e, true)

func spawn_entity(e, deferred = false) -> void:
	if deferred:
		Game.entities().call_deferred("add_child", e, true)
	else:
		Game.entities().add_child(e, true)

func server_spawn_entity(e, deferred = false) -> void:
	if !multiplayer.is_server(): return
	spawn_entity(e, deferred)

func get_authority_player() -> Player:
	return get_player(multiplayer.get_unique_id())

func get_host_player() -> Player:
	return get_player(1)

func get_other_players() -> Array[Player]:
	var ap = get_authority_player()
	var other_players: Array[Player]
	for p in get_tree().get_nodes_in_group("players"):
		if p.name != ap.name:
			other_players.append(p)
	return other_players

func save_and_clear_local_player() -> void:
	var local_player = get_host_player()
	if local_player:
		#SaveManager.store_player_data(local_player)
		local_player.queue_free()

func get_player(peer_id: int) -> Player:
	for player in get_tree().get_nodes_in_group("players"):
		if player.get_multiplayer_authority() == peer_id:
			return player
	return null

#func get_enemy_by_name(entity_name: String) -> Enemy:
	#for e: Enemy in get_tree().get_nodes_in_group("enemies"):
		#if e.name == entity_name: return e
	#return null
