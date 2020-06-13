extends Player

func flipRays(input):
	collisionDirection.scale.x = input
	attackRay.scale.x = input

func addRayExceptions():
	for ray in raycasts:
		ray.add_exception(get_parent().get_node("Map/TileMap"))
		ray.add_exception(get_node("Collisions"))
		for child in get_parent().get_node("Map/Items").get_children():
			ray.add_exception(child)
	for child in get_parent().get_node("Map/Enemies").get_children():
		enemies.append(child)
