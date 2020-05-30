extends Object

class_name Item

var held : bool
var type : int
var durability : float
var damage : float
var sprite : String
var collisionShape : Vector2

func _init(init_type : int, init_dura : float, init_damage : float, init_sprite : String, init_collisionShape : Vector2, init_held : bool):
	type = init_type
	held = init_held
	durability = init_dura
	damage = init_damage
	sprite = init_sprite
	collisionShape = init_collisionShape
