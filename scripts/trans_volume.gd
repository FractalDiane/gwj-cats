extends Area3D

@export var train_manager: TrainManager
@export var direction: Statics.Direction

func _on_body_entered(_body):
	train_manager.move_direction(direction)
	
