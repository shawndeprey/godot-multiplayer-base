class_name PlayerStateIdle extends PlayerState

@onready var walk: Node = $"../Walk"

func state_name() -> String:
	return "Idle"

func enter() -> void:
	owner.update_animation("idle")
	owner.direction.halt()

func process(_delta: float) -> PlayerState:
	if !owner.direction.zero(): return walk
	owner.velocity = Vector2.ZERO
	return null
