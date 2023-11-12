class_name Minigame
extends Node2D

signal minigame_done(success: bool, data: int)

signal early_return_send(success: bool, data: int)

func exit_task() -> void:
	minigame_done.emit(false, 0)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("exit"):
			exit_task()

func early_return_requested():
	# by default, return (false, 0) if data is requested before minigame has closed
	# (train control minigame is only one so far that can have returnable data before minigame is closed)
	early_return_send.emit(false, 0)
