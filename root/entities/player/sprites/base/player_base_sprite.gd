@tool
class_name PlayerBaseSprite extends Sprite2D

var followers: Array[Sprite2D] = []
var previous_frame: int = -1

func _ready() -> void:
	followers = []
	update_followers()

func _process(_delta):
	if Engine.is_editor_hint():
		if frame != previous_frame:
			previous_frame = frame
			update_followers()

func update_followers() -> void:
	for f in followers:
		if f == null: continue
		f.frame = frame
