class_name InteractionActivatorComponent
extends Node3D

var focused_object: InteractionReceiverComponent = null

func try_interact() -> void:
	if focused_object != null:
		print("INTERACTED WITH %s" % focused_object.get_parent().name)


func _on_interact_area_area_entered(area: Area3D):
	focused_object = area.get_parent() as InteractionReceiverComponent


func _on_interact_area_area_exited(area: Area3D):
	focused_object = null
