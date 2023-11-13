extends Node3D

signal task_done(success: bool, data: int)

signal early_return_request()
signal early_task_return(success: bool, data: int)

@export_file("*.tscn") var minigame_scene := String()

@onready var interaction_component := $InteractionReceiverComponent as InteractionReceiverComponent

# minigame ref
var minigame: Minigame

func _ready():
	interaction_component.interacted_with.connect(_on_interacted)


func _on_interacted(player: Player) -> void:
	player.block_movement = true
	if (!task_done.is_connected(player.on_task_done)):
		task_done.connect(player.on_task_done)
	launch_minigame()


func launch_minigame() -> void:
	if not minigame_scene.is_empty() and minigame == null:
		var scene := load(minigame_scene)
		if scene != null:
			minigame = (scene as PackedScene).instantiate() as Minigame
			get_tree().current_scene.add_child(minigame)
			minigame.minigame_done.connect(_minigame_done)
			minigame.early_return_send.connect(_early_return_sent)
			early_return_request.connect(minigame.early_return_requested)


func _minigame_done(success: bool, data: int):
	minigame.queue_free()
	minigame = null
	
	print("minigame success: " + str(success) + ", minigame data: " + str(data))
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
