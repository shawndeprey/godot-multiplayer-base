class_name Player extends CharacterEntity
@export var peer_id: int

# Components
@onready var state_machine: PlayerStateMachine = $Components/StateMachine
@onready var direction: PlayerDirection = $Components/Direction
@onready var base_animations: SyncedAnimationPlayer = $Components/Animations/BaseAnimations

func _ready() -> void:
	super()
	add_to_group("players")
	set_process_input(is_multiplayer_authority())
	if is_multiplayer_authority():
		state_machine.initialize()

func update_animation(state: String) -> void:
	if !is_multiplayer_authority(): return
	base_animations.pla({anim = state + "_" + direction.animation_direction()})
