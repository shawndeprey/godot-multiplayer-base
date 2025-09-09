class_name Root extends Node2D

@onready var world: Node2D = $World
@onready var multiplayer_manager: MultiplayerManager = $MultiplayerManager

func _ready() -> void:
	# TESTING - TEMPORARY INIT LOGIC
	multiplayer_manager._spawn_local_player()

func reset_game() -> void:
	world.reset_world_and_players()
