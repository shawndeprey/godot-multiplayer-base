class_name PlayerState extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# What happens when the player inits this state?
func init() -> void:
	pass

# What happens when the player enters this state?
func enter() -> void:
	pass

# What happens when the player exits this state?
func exit() -> void:
	pass

# What happens during the _process update in this State?
func process(_delta: float) -> PlayerState:
	return null

# What happens during the _physics_process update in this State?
func physics(_delta: float) -> PlayerState:
	return null

# What happens with input events in this State?
func handle_input(_event: InputEvent) -> PlayerState:
	return null

func should_ignore_input() -> bool:
	#if Game.root().ui.is_active(): return true
	if !get_owner().visible: return true
	return false

func state_name() -> String:
	return "State"
