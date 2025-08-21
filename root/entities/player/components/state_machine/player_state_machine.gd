class_name PlayerStateMachine extends Node

# Networked Variables
@export var current_state_name: String

var states: Array[PlayerState]
var prev_state: PlayerState
var current_state: PlayerState
var next_state: PlayerState
@onready var idle: PlayerStateIdle = $Idle

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	change_state(current_state.process(_delta))

func _physics_process(_delta: float) -> void:
	change_state(current_state.physics(_delta))

func _unhandled_input(_event: InputEvent) -> void:
	if current_state.should_ignore_input(): return 
	change_state(current_state.handle_input(_event))

func initialize() -> void:
	states = []
	for c in get_children():
		if c is PlayerState: states.append(c)
	if states.size() == 0: return
	for state in states:
		state.init()
	change_state(states[0]) # Initialize to "idle"
	process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: PlayerState) -> void:
	if new_state == null || new_state == current_state: return
	next_state = new_state
	if current_state: current_state.exit()
	
	# Enter new state
	prev_state = current_state
	current_state = new_state
	current_state.enter()
	current_state_name = current_state.state_name()

func get_state_property(_state: String, _property: String):
	return find_child(_state).get(_property)
