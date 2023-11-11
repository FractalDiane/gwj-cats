extends Node3D

@onready var interaction_component := $InteractionReceiverComponent as InteractionReceiverComponent
@onready var jump_point := $JumpPoint as JumpPoint

func _ready() -> void:
	interaction_component.interacted_with.connect(_on_interacted)


func _on_interacted(player: Player) -> void:
	player.jump_to_jump_point(jump_point, false)
