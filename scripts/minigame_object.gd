extends Node3D

signal task_done(success: bool, data: int)

signal early_return_request()
signal early_task_return(success: bool, data: int)

@export_file("*.tscn") var minigame_scene := String()

@onready var interaction_component := $InteractionReceiverComponent as InteractionReceiverComponent

# minigame ref
var minigame: Minigame

var minigame_overlay: Control


func _ready():
	interaction_component.interacted_with.connect(_on_interacted)
	minigame_overlay = HUD.hud_root.get_node("MinigameOverlay")


func _on_interacted(player: Player) -> void:
	player.set_block_movement(true)
	player.set_block_interaction(true)
	if (!task_done.is_connected(player.on_task_done)):
		task_done.connect(player.on_task_done)
	
	launch_minigame()


func launch_minigame() -> void:
	if not minigame_scene.is_empty() and minigame == null:
		var scene := load(minigame_scene)
		if scene != null:
			minigame = (scene as PackedScene).instantiate() as Minigame
			if (minigame_overlay != null):
				minigame_overlay.get_node("SubViewportContainer/SubViewport").add_child(minigame)
				minigame_overlay.visible = true
				minigame.minigame_done.connect(_minigame_done)
				minigame.early_return_send.connect(_early_return_sent)
				early_return_request.connect(minigame.early_return_requested)


func _minigame_done(success: bool, data: int):
	minigame.queue_free()
	minigame = null
	
	if (minigame_overlay != null):
		minigame_overlay.visible = false
	
	print("minigame success: " + str(success) + ", minigame data: " + str(data))
	
	## really dumb but kinda funny, remove later
	# (spawns a permanent icon.svg at your mouse position if minigame returned with a boiler explosion)
	
	if (data == 1):
		var icon := load("res://icon.svg")
		var guy := Sprite2D.new()
		guy.texture = icon
		get_tree().current_scene.add_child(guy)
		guy.position = get_viewport().get_mouse_position()
		guy.scale.x = 20
		guy.scale.y = 4
		
		var ydntym := load("res://audio/you_did_not_take_your_meds.wav")
		var papyrus := AudioStreamPlayer.new()
		get_tree().current_scene.add_child(papyrus)
		papyrus.stream = ydntym
		papyrus.play()
	
	
	task_done.emit(success, data)


func _early_return_sent(success: bool, data: int):
	print("minigame early return: " + str(success) + ", minigame data: " + str(data))
	early_task_return.emit(success, data)
	

# to be connected to signal from task manager for when it wants 
func _on_early_task_return_request():
	early_return_request.emit()


######################################
### FOR TESTING, REMOVE LATER!!!!! ###
######################################
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F10:
			early_return_request.emit()
