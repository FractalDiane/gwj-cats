class_name PlayerCamera
extends Camera3D

signal move_started()
signal move_finished()

enum Direction {
	Left,
	Right,
}

func _ready() -> void:
	pass # Replace with function body.



func _process(_delta) -> void:
	pass


func move_car(direction: Direction) -> void:
	var dir := 11 if direction == Direction.Right else -11
	var tween := create_tween()
	tween.tween_property(self, ^"position:x", position.x + dir, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	move_started.emit()
	tween.finished.connect(_on_move_finished)
	
	
func _on_move_finished() -> void:
	move_finished.emit()
