extends Area2D

var itemObject

func _ready():
	itemObject = preload("res://src/Item.gd").new(-1, -1, -1, "res://assets/items/test/test_item.png", Vector2(4, 4), false)
	self.connect("body_shape_entered", get_parent().get_parent().get_parent().get_node("Player"), "handle_item_pickup", [self])
