class_name Entity extends CharacterBody2D

@export var target_position: Vector2

func _ready() -> void:
	add_to_group("entities")
	motion_mode = MOTION_MODE_FLOATING

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	move_and_slide()
	target_position = global_position
