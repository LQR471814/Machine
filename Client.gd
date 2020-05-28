extends Node2D

onready var tileMap = $TileMap
onready var menu = $Menu
onready var multiplayerDialog = $MultiplayerDialog
var PlayerInstance = null

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())

func _on_Multiplayer_button_down():
	menu.visible = false
	multiplayerDialog.visible = true

func _on_Singleplayer_button_down():
	menu.visible = false
	tileMap.visible = true
	PlayerInstance = preload("res://Player.tscn").instance()
	add_child(PlayerInstance)


func _on_Back_button_down():
	multiplayerDialog.visible = false
	menu.visible = true
