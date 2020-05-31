extends Node2D

func _ready():
	pass

func add_item(node):
	get_node("Items").add_child(node)
	
func remove_item(node):
	get_node("Items").remove_child(node)
