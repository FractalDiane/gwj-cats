extends Node3D

signal task_done(success: bool, data: int)

@export_file("*.tscn") var minigame_scene := String()

@onready var interaction_component := $InteractionReceiverComponent as InteractionReceiverComponent

# minigame ref
var minigame: Minigame

func _ready():
	interaction_component.interacted_with.connect(_on_interacted)


func _on_interacted(_player: Player) -> void:
	launch_minigame()


func launch_minigame() -> void:
	if not minigame_scene.is_empty() and minigame == null:
		var scene := load(minigame_scene)
		if scene != null:
			minigame = (scene as PackedScene).instantiate() as Minigame
			get_tree().current_scene.add_child(minigame)
			minigame.minigame_done.connect(_minigame_done)


func _minigame_done(success: bool, data: int):
	minigame.queue_free()
	minigame = null
	
	print("minigame success: " + str(success) + ", minigame data: " + str(data))
	task_done.emit(success, data)
