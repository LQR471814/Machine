extends KinematicBody2D

const GRAVITY = 300
const FRICTION = 0.05

var motion = Vector2.ZERO

func _ready():
	get_parent().get_parent().get_parent().get_node("Player").connect("PlayerCollide", self, "playerCollision")

func _process(delta):
	motion.x = lerp(motion.x, 0, FRICTION)
	motion.y += GRAVITY * delta
	motion = move_and_slide(motion, Vector2.UP, false, 4, 0.785398, false)

func playerCollision(motionVector):
	motion.x = motionVector.x * 0.75
