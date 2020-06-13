extends Player

func onCrouch(input):
	runCollider.disabled = true
	crouchCollider.disabled = false
	
	handItemSprite.get_node("Animations").play("idle")
	
	if input != 0:
		sprite.flip_h = input < 0
		utils.flipRays(input)
	
	handItemSprite.flip_h = input < 0
	if sprite.flip_h == true:
		handItemSprite.position.x = handItemSprite.position.x * -1
		handItemSprite.flip_h = true
	
	sprite.animation = "Crouch"
	sprite.playing = true
	
	animationPlayer.stop()
