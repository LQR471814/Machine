extends Node2D

onready var menu = $Menu
onready var multiplayerDialog = $MultiplayerDialog
onready var help = $Help
var ClientInstance = null
var toggleControls = -1

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())

func _on_Multiplayer_button_down():
	menu.visible = false
	multiplayerDialog.visible = true

func _on_Singleplayer_button_down():
	menu.visible = false
	ClientInstance = preload("res://Client.tscn").instance()
	ClientInstance.init(null)
	add_child(ClientInstance)

func _on_Back_button_down():
	multiplayerDialog.visible = false
	menu.visible = true

func _on_Exit_button_down():
	get_tree().quit()

func _on_Join_button_down():
	var ip = multiplayerDialog.get_node("HBoxContainer/VBoxContainer/IpInput/IpInput/LineEdit").text
	var port = multiplayerDialog.get_node("HBoxContainer/VBoxContainer/PortInput/PortInput/LineEdit").text
	connectToServer(ip, port)
		
func connectToServer(ip, port):
	var clientSocket = StreamPeerTCP.new()
	clientSocket.connect_to_host(ip, int(port))
	clientSocket.set_no_delay(true)
	
	if clientSocket.is_connected_to_host() == false:
		get_node("ConfirmationDialog").popup()
		return
	else:
		ClientInstance.init(clientSocket)

func _on_Controls_button_down():
	toggleControls *= -1
	if toggleControls > 0:
		help.visible = true
	else:
		help.visible = false
