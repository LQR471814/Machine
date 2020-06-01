extends KinematicBody2D

const GRAVITY = 300

var motion = Vector2.ZERO

func _ready():
	pass

func _process(delta):
	motion.y += GRAVITY * delta
	motion = move_and_slide(motion, Vector2.UP)
