extends Area2D

class_name ItemScript

var itemObject
const itemCategories = {"STATIC": 0, "MELEE_WEAPON": 1}

func _ready():
	var itemCategory = itemCategories[get_parent().item_category]
	
	#? Construct object based off of item configuration
	itemObject = load("res://src/controllers/item/Item.gd").new(get_parent().type, get_parent().durability, get_parent().damage, get_parent().spritePath, get_parent().held, get_parent().onBack, get_parent().scenePath, itemCategory)
	
	#? Misc Configuration
	self.scale = Vector2(0.75, 0.75)
	
	#? Set correct collision layer
	self.set_collision_layer_bit(1, true)
	self.set_collision_mask_bit(1, true)
	
	self.connect("body_shape_entered", get_parent().get_parent().get_parent().get_parent().get_node("Player"), "handle_item_pickup", [self])
