class_name Entity extends CharacterBody2D

func _ready() -> void:
	add_to_group("entities")
	motion_mode = MOTION_MODE_FLOATING
