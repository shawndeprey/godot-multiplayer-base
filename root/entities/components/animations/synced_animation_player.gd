class_name SyncedAnimationPlayer extends AnimationPlayer

var rpc_ready: bool = false

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	rpc_ready = true
	
func pla(args: Dictionary) -> void:
	if !is_multiplayer_authority(): return
	network_play(args) # Call locally
	if !rpc_ready: return
	#MP.rpc_layer(owner.layer, self, "network_play", [args])
	rpc("network_play", args)

func seek_to(seconds: float, update: bool = false, update_only: bool = false) -> void:
	if !is_multiplayer_authority(): return
	network_seek(seconds, update, update_only) # Call locally
	if !rpc_ready: return
	#MP.rpc_layer(owner.layer, self, "network_seek", [seconds, update, update_only])
	rpc("network_seek", seconds, update, update_only)

func play_seek_pause(args: Dictionary) -> void:
	if !is_multiplayer_authority(): return
	network_play_seek_pause(args) # Call locally
	if !rpc_ready: return
	#MP.rpc_layer(owner.layer, self, "network_play_seek_pause", [args])

@rpc("any_peer", "call_local", "reliable") # Called on ALL clients, including self
func network_play(args: Dictionary) -> void:
	#if !multiplayer.is_server() and !get_owner().on_client_layer(): return
	if args.has("speed_scale"): speed_scale = args["speed_scale"]
	if args.has("anim"):
		if is_playing():
			stop()
			await get_tree().process_frame
		play(args["anim"])

@rpc("any_peer", "call_local", "reliable") # Called on ALL clients, including self
func network_seek(seconds: float, update: bool = false, update_only: bool = false) -> void:
	#if !multiplayer.is_server() and !get_owner().on_client_layer(): return
	seek(seconds, update, update_only)

@rpc("any_peer", "call_local", "reliable") # Called on ALL clients, including self
func network_play_seek_pause(args: Dictionary) -> void:
	#if !multiplayer.is_server() and !get_owner().on_client_layer(): return
	if args.has("anim"): play(args["anim"])
	if args.has("seek"): seek(args["seek"], true)
	pause()
