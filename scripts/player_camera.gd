class_name PlayerCamera
extends Camera3D

func _ready() -> void:
	pass # Replace with function body.



func _process(_delta) -> void:
	pass


func move_car(tween: Tween, direction: Statics.Direction) -> void:
	var dir := 1 if direction == Statics.Direction.Right else -1
	tween.tween_property(self, ^"position:x", position.x + dir * 11, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	
	

