extends Node2D

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second()) #? Sync physics process to monitor refresh rate
