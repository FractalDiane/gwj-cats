extends Node3D

class_name MinigameObject

signal task_done(success: bool, data: int, source: MinigameObject)

signal early_return_request()
signal early_task_return(success: bool, data: int)

@export_file("*.tscn") var minigame_scene := String()

@onready var interaction_component := $InteractionReceiverComponent as InteractionReceiverComponent

# minigame ref
var minigame: Minigame

var minigame_overlay: Control

func set_active():
	var outline := get_node("outline")
	outline.set_visible(true)

func set_inactive():
	var outline := get_node("outline")
	
	print("here")
	print(outline)
	outline.set_visible(false)

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
	
	task_done.emit(success, data, self)


func _early_return_sent(success: bool, data: int):
	print("minigame early return: " + str(success) + ", minigame data: " + str(data))
	early_task_return.emit(success, data)
	

# to be connected to signal from task manager for when it wants 
func _on_early_task_return_request():
	early_return_request.emit()
