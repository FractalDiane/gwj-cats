extends Node3D
class_name TrainManager

signal move_started()
signal move_finished()

var active_car_index: int = 1
@export var player_camera : PlayerCamera
@export var player : Player

func _ready():
	pass # Replace with function body.


func _process(_delta):
	if Input.is_action_just_pressed(&"debug_left"):
		move_direction(Statics.Direction.Left)
	elif Input.is_action_just_pressed(&"debug_right"):
		move_direction(Statics.Direction.Right)
		

func move_direction(d: Statics.Direction):
	var tween := create_tween()
	move_started.emit()
	player_camera.move_car(tween, d)
	player.move_car(tween, d)
	tween.finished.connect(_on_move_finished)
	active_car_index = active_car_index + (1 if d == Statics.Direction.Right else -1)
	
func _on_move_finished() -> void:
	move_finished.emit()
