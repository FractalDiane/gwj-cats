class_name Minigame
extends Node

signal minigame_done(success: bool, data: int)

func exit_task() -> void:
	minigame_done.emit(false, 0)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("exit"):
			exit_task()
