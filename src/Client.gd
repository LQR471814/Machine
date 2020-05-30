extends Node

func _ready():
	pass

func init(clientSocket):
	$Player.init(clientSocket)
