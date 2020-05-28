extends KinematicBody2D

const ACCELERATION = 1024
const MAX_SPEED = 150
const FRICTION = 1
const AIR_RESISTENCE = 0.1
const GRAVITY = 300
const JUMP_FORCE = 120

const DASH_FORCE = 5000
const DASH_FRAMES = 10
const FALL_THRESH = 100
var dashedFrames = 0

const SPRINT_THRESH = 20
const DASH_WAIT_TIME = 2

var motion = Vector2.ZERO
var canDash = true

onready var sprite = $Sprite
onready var runCollider = $RunCollision
onready var crouchCollider = $CrouchCollision
onready var animationPlayer = $Animations
onready var dashTimer = $DashTimer
onready var dashEffectLeft = $DashEffectLeft
onready var dashEffectRight = $DashEffectRight
onready var helpGui = $Help

var toggledHelp = -1

func _ready():
	crouchCollider.disabled = true
	runCollider.disabled = false
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").animation = "DashReady"
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").speed_scale = 1

func _physics_process(delta):
	var input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if Input.is_action_just_pressed("help"):
		toggledHelp = toggledHelp * -1
	
	if toggledHelp > 0:
		helpGui.visible = true
	else:
		helpGui.visible = false
	
	if dashedFrames != 0: #? If dashing
		motion.x = DASH_FORCE * input / DASH_FRAMES
		motion.y += GRAVITY * delta / 2#? Apply gravity
		dashedFrames -= 1
	else: #? If not dashing
		dashEffectLeft.emitting = false
		dashEffectRight.emitting = false

		if Input.is_action_pressed("ui_down"): #? If crouching
			motion.x = input * MAX_SPEED / 3
			
			if canDash == true:
				if Input.is_action_pressed("dash") and Input.is_action_pressed("ui_left") or Input.is_action_pressed("dash") and Input.is_action_pressed("ui_right"): #? If user dashed	
					if input > 0:
						dashEffectRight.emitting = true
					else:
						dashEffectLeft.emitting = true
					
					sprite.flip_h = input < 0 #? Flip sprite according to direction
					motion.x = DASH_FORCE * input / DASH_FRAMES #? Apply dash force
					canDash = false
					dashTimer.wait_time = DASH_WAIT_TIME
					dashTimer.start()
					get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").speed_scale = float(11) / float(DASH_WAIT_TIME)
					get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").animation = "DashCooldown"
					dashedFrames = DASH_FRAMES
			
			runCollider.disabled = true
			crouchCollider.disabled = false
			
			if input != 0:
				sprite.flip_h = input < 0
			sprite.animation = "Crouch"
			sprite.playing = true
			
			animationPlayer.stop()
		elif Input.is_action_pressed("ui_down") == false: #? If not crouching
			if is_on_floor(): #? If on floor
				
				if input == 0: #? If no input (Friction applier)
					motion.x = lerp(motion.x, 0, FRICTION)
				
				#? Visuals
				if Input.is_action_just_pressed("ui_up"): #? If jumping
					motion.y = -JUMP_FORCE
					
					sprite.animation = "Run"
					sprite.frame = 2
					sprite.playing = false
					animationPlayer.stop()
				else: #? If not jumping
		#			if motion.x == MAX_SPEED or motion.x > MAX_SPEED - SPRINT_THRESH or motion.x == -MAX_SPEED or motion.x < -MAX_SPEED + SPRINT_THRESH: #? If running
		#				sprite.animation = "Run"
				
					if motion.x == 0: #? If Still
						sprite.animation = "Acceleration"
						sprite.playing = false
				
				#? Disable crouch hitbox
				crouchCollider.disabled = true
				runCollider.disabled = false
				
				#? Replace crouch visuals with still visuals if still
				if motion.x == 0: #? If Still
					sprite.animation = "Acceleration"
					sprite.playing = false
					animationPlayer.stop()
				
				#? Movement Handler
				if input != 0: #? If user moved left or right
			#		motion.x += input * ACCELERATION * delta
			#		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
					
					motion.x = input * MAX_SPEED
					
					#? Replace crouch visuals with run visuals if running
					sprite.flip_h = input < 0 #? Flip sprite according to direction
					sprite.animation = "Run"
					sprite.playing = true
					animationPlayer.play("Run")
			else: #? If airborne
				animationPlayer.stop()
					
				if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:
					motion.y = -JUMP_FORCE/2
				
				if input != 0: #? If user moved left or right
			#		motion.x += input * ACCELERATION * delta
					motion.x = input * MAX_SPEED
						
					sprite.flip_h = input < 0 #? Flip sprite according to direction
				
				if motion.y + (GRAVITY * delta) < FALL_THRESH: #? Short fall
					sprite.animation = "Run"
					sprite.frame = 0
					sprite.playing = false
				else: #? Long fall
					sprite.animation = "Fall"
					sprite.frame = 0
					sprite.playing = false
					
				motion.x = lerp(motion.x, 0, AIR_RESISTENCE)
	
		motion.y += GRAVITY * delta #? Apply gravity
	
	motion = move_and_slide(motion, Vector2.UP)

func _on_DashTimer_timeout():
	canDash = true
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").speed_scale = 1
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").animation = "DashReady"
