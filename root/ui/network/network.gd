class_name NetworkGui extends CanvasLayer

@onready var host_data: Label = $Control/HostData
@onready var host: Button = $Control/VBoxContainer/HostGame
@onready var join: Button = $Control/VBoxContainer/JoinGame

func _ready() -> void:
	reset_networking()

func _on_host_game_pressed() -> void:
	var mm: MultiplayerManager = Game.mm()
	if mm == null: return
	if !mm.host_game_fail.is_connected(_on_host_game_fail):
		mm.host_game_fail.connect(_on_host_game_fail)
	mm.host_game()
	hide()
	if !mm.ip_data_gathered.is_connected(_on_ip_data_ready):
		mm.ip_data_gathered.connect(_on_ip_data_ready)
	mm.get_ip_addresses()

func _on_join_game_pressed() -> void:
	#var ip = ip_input.text.strip_edges()
	var ip: String = "localhost"
	if ip == "":
		print("[UI] ERROR: No IP provided!")
		return

	var mm: MultiplayerManager = Game.mm()
	if mm == null: return
	Game.world().save_and_clear_local_player()
	hide()
	host.disabled = true
	join.disabled = true
	if !mm.client_connection_fail.is_connected(_on_client_connection_fail):
		mm.client_connection_fail.connect(_on_client_connection_fail)
	Game.world().reset_world()
	mm.join_game(ip)

func _on_host_game_fail() -> void:
	print("[NETWORK GUI] Failed to host game...")
	host.disabled = false
	join.disabled = false

func _on_client_connection_fail() -> void:
	host.disabled = false
	join.disabled = false
	# TBD: Add notification of failure to connect
	var mm: MultiplayerManager = Game.mm()
	if mm == null: return
	mm._spawn_local_player()

func _on_ip_data_ready() -> void:
	var mm: MultiplayerManager = Game.mm()
	if mm.is_hosting:
		host_data.text = "Hosting on: UDP Port 4242\nLocal IP: " + mm.ip_data.localhost + "\nLAN IP: " + mm.ip_data.lan + "\nPublic IP: " + mm.ip_data.public
		host_data.show()
	else:
		reset_networking()

func reset_networking() -> void:
	host_data.hide()
