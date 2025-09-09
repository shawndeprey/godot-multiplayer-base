class_name Player extends CharacterEntity
@export var peer_id: int

# Components
@onready var state_machine: PlayerStateMachine = $Components/StateMachine
@onready var direction: PlayerDirection = $Components/Direction
@onready var base_animations: SyncedAnimationPlayer = $Components/Animations/BaseAnimations

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	super()
	add_to_group("players")
	set_process_input(is_multiplayer_authority())
	if is_multiplayer_authority():
		state_machine.initialize()

@rpc("any_peer", "call_local")
func connected_to_server() -> void:
	#if SaveManager.has_stored_data(): persistence.apply_state(SaveManager.player_data)
	print("[PLAYER] ", name, " connected to server. peer_id: ", multiplayer.get_unique_id())
	global_position = Vector2(480, 270)

func update_animation(state: String) -> void:
	if !is_multiplayer_authority(): return
	base_animations.pla({anim = state + "_" + direction.animation_direction()})
