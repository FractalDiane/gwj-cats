extends Node3D

@export_file("*.tscn") var minigame_scene := String()

@onready var interaction_component := $InteractionReceiverComponent as InteractionReceiverComponent

func _ready():
	interaction_component.interacted_with.connect(launch_minigame)


func _process(delta):
	pass


func launch_minigame() -> void:
	var scene := load(minigame_scene)
	if scene != null:
		var minigame := (scene as PackedScene).instantiate()
		get_tree().current_scene.add_child(minigame)
