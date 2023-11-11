class_name InteractionReceiverComponent
extends Node3D

signal interacted_with(player: Player)

func interact(player: Player) -> void:
	interacted_with.emit(player)
