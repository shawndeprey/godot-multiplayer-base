extends Node

func root() -> Node:
	return self.get_node_or_null("/root/Root")

func mm() -> Node:
	return self.get_node_or_null("/root/Root/MultiplayerManager")

func world() -> Node:
	return self.get_node_or_null("/root/Root/World")

func entities() -> Node:
	return self.get_node_or_null("/root/Root/World/Entities")
