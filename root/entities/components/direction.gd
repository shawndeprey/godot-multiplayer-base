class_name Direction extends Node

const DIR_4: Array = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const DIR_8 : Array[Vector2] = [
	Vector2(0,-1), # UP 
	Vector2(1,-1), # UP/RIGHT
	Vector2(1,0),  # RIGHT
	Vector2(1,1),  # DOWN/RIGHT
	Vector2(0,1),  # DOWN
	Vector2(-1,1), # DOWN/LEFT
	Vector2(-1,0), # LEFT
	Vector2(-1,-1), # UP/LEFT
]

@export var cardinal: Vector2 = Vector2.DOWN
@export var current: Vector2 = Vector2.ZERO

func heading() -> Vector2:
	if current != Vector2.ZERO: return current
	return cardinal

func random_4() -> Vector2:
	return DIR_4[randi_range(0, 3)]

func direction_4_id() -> int:
	return int(round(fposmod(current.angle() + PI/2, TAU) / TAU * DIR_4.size())) % DIR_4.size()

func animation_direction_4() -> String:
	if cardinal == Vector2.UP: return "up"
	elif cardinal == Vector2.RIGHT: return "right"
	elif cardinal == Vector2.DOWN: return "down"
	elif cardinal == Vector2.LEFT: return "left"
	else: return "down"

func random_8() -> Vector2:
	return DIR_8[randi_range(0, 7)]

func direction_8_id() -> int:
	return int(round(fposmod(current.angle() + PI/2, TAU) / TAU * DIR_8.size())) % DIR_8.size()

func animation_direction_8() -> String:
	if cardinal == DIR_8[0]: return "up"
	elif cardinal == DIR_8[1]: return "up_right"
	elif cardinal == DIR_8[2]: return "right"
	elif cardinal == DIR_8[3]: return "down_right"
	elif cardinal == DIR_8[4]: return "down"
	elif cardinal == DIR_8[5]: return "down_left"
	elif cardinal == DIR_8[6]: return "left"
	elif cardinal == DIR_8[7]: return "up_left"
	else: return "down"
