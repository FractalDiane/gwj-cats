extends Node3D

@export_file("*.tscn") var minigame_scene := String()

@onready var interaction_component := $InteractionReceiverComponent as InteractionReceiverComponent

func _ready():
	interaction_component.interacted_with.connect(_on_interacted)


func _on_interacted(_player: Player) -> void:
	launch_minigame()


func launch_minigame() -> void:
	if not minigame_scene.is_empty():
		var scene := load(minigame_scene)
		if scene != null:
			var minigame := (scene as PackedScene).instantiate()
			get_tree().current_scene.add_child(minigame)
