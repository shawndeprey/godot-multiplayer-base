class_name UI extends CanvasLayer

@onready var network: NetworkGui = $Network

func reset_ui() -> void:
	network.reset_networking()
