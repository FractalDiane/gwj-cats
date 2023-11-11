extends Node

var sources_pausing_time := 0

@onready var level_timer := $LevelTimer as Timer

func push_time_pause_source() -> void:
	sources_pausing_time += 1
	level_timer.paused = true
	
	
func pop_time_pause_source() -> void:
	if sources_pausing_time > 0:
		sources_pausing_time -= 1
		if sources_pausing_time == 0:
			level_timer.paused = false
