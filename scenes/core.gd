extends Node3D

@export var normalTaskCandidates: Array[Node3D]
@export var leverTask: Node3D
@export var boilerTask: Node3D

@export var normalTaskBaseFrequency: float
@export var engineTaskBaseFrequency: float
@export var taskTimeRandomnessMultiplier: float
@export var normalTaskWindow: float
@export var engineTaskWindow: float
@export var difficultyScaling: float

var minigame_scene := preload("res://prefabs/minigame_object.tscn")
var random: RandomNumberGenerator

var taskWindows: Array[float]
var difficulty: int
var normalTaskFrequency: float = normalTaskBaseFrequency
var engineTaskFrequency: float = engineTaskBaseFrequency

# Called when the node enters the scene tree for the first time.
func _ready():
	taskWindows.resize(normalTaskCandidates.size() + 2)
	taskWindows.fill(0 as float)
	random = RandomNumberGenerator.new()
	
	difficulty = 0
	
	LevelManager.level_timer.timeout.connect(_on_normal_timer_timeout)
	LevelManager.level_timer.wait_time = normalTaskBaseFrequency
	LevelManager.level_timer2.timeout.connect(_on_engine_timer_timeout)
	LevelManager.level_timer2.wait_time = engineTaskBaseFrequency	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	if (LevelManager.sources_pausing_time <= 0):
		updateTimers(delta)


func _on_normal_timer_timeout():
	LevelManager.level_timer.wait_time = normalTaskFrequency * (1 + (random.randf() * taskTimeRandomnessMultiplier))
	
	taskWindows[random.randi_range(0, taskWindows.size()-1) + 2] = normalTaskWindow


func _on_engine_timer_timeout():
	LevelManager.level_timer2.wait_time = engineTaskFrequency * (1 + (random.randf() * taskTimeRandomnessMultiplier))
	difficulty += 1
	
	taskWindows[random.randi_range(0, 1)] = engineTaskWindow


func updateTimers(d : int):
	for i in taskWindows.size():
		taskWindows[i] = max(taskWindows[i] - d, 0)
