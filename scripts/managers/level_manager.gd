extends Node

@export var current_level: Level

var sources_pausing_time := 0
var pause_text: Node2D = null

@onready var level_timer := $LevelTimer as Timer
@export var train_manager: TrainManager

func _ready():
	if current_level:
		start_level(current_level)

func start_level(level: Level) -> void:
	current_level = level
	train_manager.instantiate_trains(level.train_cars)
	


func push_time_pause_source() -> void:
	sources_pausing_time += 1
	level_timer.paused = true
	pause_text = preload("res://scenes/pawsed_text.tscn").instantiate() as Node2D
	pause_text.position = Vector2(960, 540)
	pause_text.scale = Vector2(0.5, 0.5)
	HUD.add_hud_child(pause_text)
	
	
func pop_time_pause_source() -> void:
	if sources_pausing_time > 0:
		sources_pausing_time -= 1
		if sources_pausing_time == 0:
			level_timer.paused = false
			pause_text.queue_free()
