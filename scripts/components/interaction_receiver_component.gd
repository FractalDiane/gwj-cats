class_name InteractionReceiverComponent
extends Node3D

signal interacted_with()

func interact() -> void:
	print("INTERACTED WITH %s" % get_parent().name)
	interacted_with.emit()
