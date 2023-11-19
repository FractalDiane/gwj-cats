extends Node3D
class_name TrainManager

signal move_started()
signal move_finished()

var active_car_index: int = 0
var active_train_cars: Array = []

@export var player_camera : PlayerCamera
@export var player : Player

func _ready():
	if (Globals.minigame_overlay_ref == null):
		Globals.minigame_overlay_ref = get_tree().current_scene.find_child("MinigameOverlay")


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
	active_train_cars[active_car_index].fade_in_obstructor()
	active_car_index = active_car_index + (1 if d == Statics.Direction.Right else -1)
	active_train_cars[active_car_index].fade_out_obstructor()
	
func _on_move_finished() -> void:
	move_finished.emit()
	
func instantiate_trains(train_cars: Array) -> void:
	for i in range(train_cars.size()):
		var c = train_cars[i].instantiate()
		add_child(c)
		c.position = Vector3.RIGHT * i * 11
		if i == active_car_index:
			c.set_obstructor_off()
		active_train_cars.append(c)
	
