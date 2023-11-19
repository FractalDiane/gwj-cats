extends Node

@export var current_level: Level

var sources_pausing_time := 0
var pause_text: Node2D = null

@onready var level_timer := $LevelTimer as Timer
@onready var level_timer2 := $LevelTimer2 as Timer
@export var train_manager: TrainManager

func _ready():
	if current_level:
		start_level(current_level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if (sources_pausing_time <= 0):
		updateTimers(delta)

func start_level(level: Level) -> void:
	for car in train_manager.active_train_cars:
		if car.car_type == 2:
			car.force_ready()
	
	current_level = level
	train_manager.instantiate_trains(level.train_cars)
	
	for car in train_manager.active_train_cars:
		if car.car_type == 3:
			continue
		if car.car_type == 1:
			boilerTask = car.available_minigames[0]
			leverTask = car.available_minigames[1]
		else:
			for x in car.available_minigames:
				normalTaskCandidates.append(x)

	taskWindows.resize(normalTaskCandidates.size())
	taskWindows.fill(0 as float)
	hasTask.resize(normalTaskCandidates.size())
	hasTask.fill(false)
	random = RandomNumberGenerator.new()
	
	difficulty = 0
	
	level_timer.timeout.connect(_on_normal_timer_timeout)
	level_timer.wait_time = normalTaskBaseFrequency
	level_timer2.timeout.connect(_on_engine_timer_timeout)
	level_timer2.wait_time = engineTaskBaseFrequency
	
	level_timer.start()
	level_timer2.start()
	

func push_time_pause_source() -> void:
	sources_pausing_time += 1
	level_timer.paused = true
	level_timer2.paused = true
	pause_text = preload("res://scenes/pawsed_text.tscn").instantiate() as Node2D
	pause_text.position = Vector2(960, 540)
	pause_text.scale = Vector2(0.5, 0.5)
	HUD.add_hud_child(pause_text)
	
	
func pop_time_pause_source() -> void:
	if sources_pausing_time > 0:
		sources_pausing_time -= 1
		if sources_pausing_time == 0:
			level_timer.paused = false
			level_timer2.paused = false
			pause_text.queue_free()

var normalTaskCandidates: Array[Node3D]
var leverTask: Node3D
var boilerTask: Node3D

@export var normalTaskBaseFrequency: float = 1.0
@export var engineTaskBaseFrequency: float = 1.0
@export var taskTimeRandomnessMultiplier: float
@export var normalTaskWindow: float
@export var engineTaskWindow: float
@export var difficultyScaling: float

var minigame_scene := preload("res://prefabs/minigame_object.tscn")
var random: RandomNumberGenerator

var taskWindows: Array[float]
var hasTask: Array[bool]
var difficulty: int
var normalTaskFrequency: float = normalTaskBaseFrequency
var engineTaskFrequency: float = engineTaskBaseFrequency


func _on_normal_timer_timeout():
	level_timer.wait_time = normalTaskFrequency * (1 + (random.randf() * taskTimeRandomnessMultiplier))
	
	var index: int = random.randi_range(0, taskWindows.size()-1)
	while (hasTask[index]):
		index = random.randi_range(0, taskWindows.size()-1)
	addTask(index)


func _on_engine_timer_timeout():
	level_timer2.wait_time = engineTaskFrequency * (1 + (random.randf() * taskTimeRandomnessMultiplier))
	difficulty += 1
	normalTaskFrequency = normalTaskBaseFrequency * (1 - (difficulty * difficultyScaling))
	
	var index: int = random.randi_range(0, 1)
	while (hasTask[index]):
		index = random.randi_range(0, 1)
	addTask(index)


func addTask(index: int) -> void:
	taskWindows[index] = engineTaskWindow if (index <= 1) else normalTaskWindow
	hasTask[index] = true
	
	print(normalTaskCandidates.size())
	var taskObject: Node3D = normalTaskCandidates[index]
	taskObject.set_active()
	
	taskObject.task_done.connect(_on_task_done)


func _on_task_done(success: bool, data: int, source: MinigameObject):
	# yeah so i didnt think this through enough and theres no way to tell which minigame object sent this i think?
	var i:int = normalTaskCandidates.find(source)
	hasTask[i] = false
	source.set_inactive()
	if (!success):
		set_task_text("wuh-oh,,")


func set_task_text(text: String):
	HUD.task_text.text = text


func updateTimers(d : int):
	for i in taskWindows.size():
		taskWindows[i] = max(taskWindows[i] - d, 0)

