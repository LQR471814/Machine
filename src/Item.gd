extends Object

class_name Item

var held : bool
var onBack : bool
var type : int
var category : int
var durability : float
var damage : float
var sprite : String
var scene : String

func _init(init_type : int, init_dura : float, init_damage : float, init_sprite : String, init_held : bool, init_onBack : bool, init_scene : String, init_category : int):
	type = init_type
	held = init_held
	onBack = init_onBack
	durability = init_dura
	damage = init_damage
	sprite = init_sprite
	scene = init_scene
	category = init_category
