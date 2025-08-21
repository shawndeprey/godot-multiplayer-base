class_name Walk extends PlayerState

@export var move_speed: float = 140

@onready var idle: PlayerStateIdle = $"../Idle"

func state_name() -> String:
	return "Walk"

func enter() -> void:
	super()
	owner.update_animation("walk")

func process(_delta: float) -> PlayerState:
	#if Game.root().ui.is_active(): return idle
	if owner.direction.zero(): return idle
	owner.velocity = owner.direction.true_input_vector * move_speed
	if owner.direction.set_direction(): owner.update_animation("walk")
	return null
