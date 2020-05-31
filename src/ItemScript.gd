extends Area2D

var itemObject

func _ready():
	#? Construct object based off of item configuration
	print(get_parent().scenePath)
	itemObject = preload("res://src/Item.gd").new(get_parent().type, get_parent().durability, get_parent().damage, get_parent().spritePath, get_parent().held, get_parent().scenePath)
	
	#? Misc Configuration
	self.scale = Vector2(0.75, 0.75)
	
	#? Set correct collision layer
	self.set_collision_layer_bit(1, true)
	self.set_collision_mask_bit(1, true)
	
	self.connect("body_shape_entered", get_parent().get_parent().get_parent().get_parent().get_node("Player"), "handle_item_pickup", [self])
