extends Node2D

var max_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var max_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

@export var despawnBuffer: int

func _process(_delta):
	if (position.x < -despawnBuffer or position.x > max_width + despawnBuffer or
	position.y < -despawnBuffer or position.y > max_height + despawnBuffer):
		self.queue_free()
