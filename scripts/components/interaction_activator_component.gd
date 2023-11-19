class_name InteractionActivatorComponent
extends Node3D

var enabled: bool = true
var focused_object: InteractionReceiverComponent = null

func try_interact(player: Player) -> void:
	if focused_object != null and enabled:
		focused_object.interact(player)


func _on_interact_area_area_entered(area: Area3D):
	focused_object = area.get_parent() as InteractionReceiverComponent


func _on_interact_area_area_exited(_area: Area3D):
	focused_object = null
