extends Area2D

var itemObject

func _ready():
	#? Construct item index
	var itemIndex = {}
	var fObj = File.new()
	fObj.open("res://items/index.json", fObj.READ)
	itemIndex = parse_json(fObj.get_as_text())
	fObj.close()
	
	#? Get item config file from item index
	var itemConfig = {}
	var itemFile = File.new()
	itemFile.open(itemIndex[str(get_parent().itemID)], itemFile.READ)
	itemConfig = parse_json(itemFile.get_as_text())
	itemFile.close()
	
	itemObject = preload("res://src/Item.gd").new(itemConfig["type"], itemConfig["durability"], itemConfig["damage"], itemConfig["sprite"], Vector2(itemConfig["collisionShape"][0], itemConfig["collisionShape"][1]), itemConfig["held"])
	self.connect("body_shape_entered", get_parent().get_parent().get_parent().get_parent().get_node("Player"), "handle_item_pickup", [self])
