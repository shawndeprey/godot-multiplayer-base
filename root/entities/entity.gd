class_name Entity extends CharacterBody2D

@export var layer: int
@export var target_position: Vector2

# Needs to go in helpers somewhere
var replication_interval: float = 0.05 # 20 updates per second
var interpolation_speed: float = 1 / replication_interval

func _ready() -> void:
	add_to_group("entities")
	motion_mode = MOTION_MODE_FLOATING

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	move_and_slide()
	target_position = global_position

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		position = position.lerp(target_position, interpolation_speed * delta)
