extends Node2D

export var spawnLocale : Vector2

func _ready():
	get_parent().get_node("Player").position = spawnLocale

func add_item(node):
	get_node("Items").add_child(node)
	
func remove_item(node):
	get_node("Items").remove_child(node)
