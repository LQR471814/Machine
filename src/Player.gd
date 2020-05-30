extends KinematicBody2D

const ACCELERATION = 1024
const MAX_SPEED = 150
const FRICTION = 1
const AIR_RESISTENCE = 0.1
const GRAVITY = 300
const JUMP_FORCE = 140

const DASH_FORCE = 5000
const DASH_UP_FORCE = 30
const DASH_FRAMES = 10
const FALL_THRESH = 100
var dashedFrames = 0

const SPRINT_THRESH = 20
const DASH_WAIT_TIME = 2
const PICKUP_IMMUNITY = 20

var motion = Vector2.ZERO
var canDash = true
var playerSocket = null

onready var sprite = $Sprite
onready var runCollider = $RunCollision
onready var crouchCollider = $CrouchCollision
onready var animationPlayer = $Animations
onready var dashTimer = $DashTimer
onready var dashEffectLeft = $DashEffectLeft
onready var dashEffectRight = $DashEffectRight
onready var helpGui = $Help

var invSlotActions = ["inv_slot_0", "inv_slot_1", "inv_slot_2", "inv_slot_3", "inv_slot_4", "inv_slot_5"]
var toggledHelp = -1
var itemBar = [null, null, null, null, null, null]
var selected_item = 0
var pickupImmunity = 0

func _ready():
	crouchCollider.disabled = true
	runCollider.disabled = false
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").animation = "DashReady"
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").speed_scale = 1
	switchItem(selected_item)

func _process(delta):
	var input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	check_and_handle_item_drop()
	
	if pickupImmunity > 0: #? Subtract 1 frame from pickup immunity time
		pickupImmunity -= 1
	
	var itemSwitch = checkForItemSwitch() #? Check for item slot switch
	if itemSwitch != -1: #? If item slot switch is true then switch item slot
		switchItem(itemSwitch)
	
	if Input.is_action_just_pressed("help"): #? Check for toggle help
		toggledHelp = toggledHelp * -1
	
	if toggledHelp > 0:
		helpGui.visible = true
	else:
		helpGui.visible = false
	
	if dashedFrames != 0: #? If dashing
		motion.x = DASH_FORCE * input / DASH_FRAMES
		motion.y += GRAVITY * delta / 2#? Apply gravity
		motion.y -= float(DASH_UP_FORCE) / float(DASH_FRAMES)
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
					
				if Input.is_action_just_released("ui_up") and motion.y < float(-JUMP_FORCE)/2.0:
					motion.y = float(-JUMP_FORCE)/2.0
				
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

func checkForItemSwitch():
	var i = 0
	for check in invSlotActions:
		if Input.is_action_just_pressed(check):
			break
		i += 1

	if i == 6:
		return -1
	else:
		return i

func switchItem(item_index):
	for i in range(6):
		get_node("Items/Margin/ItemSlots/Item" + str(i) + "/Item").animation = "empty"
	selected_item = item_index
	get_node("Items/Margin/ItemSlots/Item" + str(item_index) + "/Item").animation = "selected"
	
#	get_node("ItemSprite")

func pick_up_item(item_node): #? Process item pickup
	var i = 0
	for item in itemBar:
		if item == null:
			itemBar[i] = item_node.itemObject
			break
		i += 1
		
	if i == 6:
		return
		
	get_parent().get_node("Items").remove_child(item_node.get_parent())
	
	get_node("Items/Margin/ItemSlots/Item" + str(i) + "/Texture").texture = load(item_node.itemObject.sprite)

func handle_item_pickup(_body_id, _body, _body_shape, _area_shape, node):
	if _body == self:
		if pickupImmunity == 0:
			call_deferred("pick_up_item", node)

func check_and_handle_item_drop(): #? Check and handle item drop
	if Input.is_action_just_pressed("drop_item"): #? If item drop key pressed
		if itemBar[selected_item] != null: #? If selected item is not empty
			get_node("Items/Margin/ItemSlots/Item" + str(selected_item) + "/Texture").texture = null #? Set dropped itemslot texture to nothing
			var n = 0 #? Item Dropped node name
			while true:
				if get_parent().find_node("Items/" + str(n)) == null: #? if name n is availible
					#? Init nodes
					var itemPhysics = RigidBody2D.new()
					var rigidBodyCollision = CollisionShape2D.new()
					var rigidBodyCollisionShape = RectangleShape2D.new()
					
					var itemNode = Area2D.new()
					var collisionNode = CollisionShape2D.new()
					var collisionShape = RectangleShape2D.new()
					var animatedSprite = AnimatedSprite.new()
					var spriteFrames = SpriteFrames.new()
					
					#? Add sprite node
					spriteFrames.add_frame("default", load(itemBar[selected_item].sprite), 0)
					animatedSprite.frames = spriteFrames
					
					#? Add item collision node
					collisionShape.extents = Vector2(8, 8)
					collisionNode.shape = collisionShape
					
					#? Add Area2D Item node
					itemNode.name = "Item"
					itemNode.scale = Vector2(0.5, 0.5)
					itemNode.set_script(load("res://src/ItemScript.gd"))
					itemNode.set_collision_layer_bit(1, true)
					itemNode.set_collision_mask_bit(1, true)
					
					itemNode.add_child(animatedSprite)
					itemNode.add_child(collisionNode)
					
					#? Item Physics
					rigidBodyCollisionShape.extents = itemBar[selected_item].collisionShape
					rigidBodyCollision.shape = rigidBodyCollisionShape
					
					itemPhysics.add_child(itemNode)
					itemPhysics.add_child(rigidBodyCollision)
					itemPhysics.position = self.position
					
					get_parent().get_node("Items").add_child(itemPhysics)
					pickupImmunity = PICKUP_IMMUNITY
					break
				
			itemBar[selected_item] = null

func _on_DashTimer_timeout():
	canDash = true
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").speed_scale = 1
	get_node("Cooldowns/Container/Cooldowns/DashCooldown/DashMargin/DashCooldown").animation = "DashReady"

func init(init_socket):
	playerSocket = init_socket
