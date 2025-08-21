class_name PlayerDirection extends Direction
# This class only supports DIR8 vectors

@export var true_input_vector: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	get_input_vectors()

func zero() -> bool:
	return current == Vector2.ZERO

func halt() -> void:
	true_input_vector = Vector2.ZERO
	current = Vector2.ZERO

func direction_8_id() -> int:
	return int(round(fposmod(current.angle() + PI/2, TAU) / TAU * DIR_8.size())) % DIR_8.size()

func get_input_vectors() -> void:
	true_input_vector = Input.get_vector("left", "right", "up", "down")
	current = true_input_vector.normalized()

func set_direction() -> bool:
	if current == Vector2.ZERO: return false

	# If direction hasn't changed, just escape without changing direction, otherwise change direction
	var new_direction: Vector2 = DIR_8[direction_8_id()]
	if new_direction == cardinal: return false
	cardinal = new_direction
	return true
	
func animation_direction() -> String:
	return animation_direction_8()
