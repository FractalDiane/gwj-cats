extends Node3D

enum environment_type {
	FOREST,
	SNOWY,
	TUNNEL
}

@export var active_environment: environment_type = environment_type.FOREST
@export var environment_speed: float = 0.5
@export var environment_templates: Dictionary = {
	environment_type.FOREST: preload("res://scenes/train_cars/environment_forest.tscn"),
	environment_type.SNOWY: null,
	environment_type.TUNNEL: null
}

var environment_position: float = 0
var environment_length: float = 160

func _ready():
	set_environment(active_environment)	

func set_environment(env_type: environment_type):
	spawn_environment(env_type)
	spawn_tunnel()
	active_environment = env_type
	
func spawn_tunnel():
	pass
	
func spawn_environment(env_type: environment_type):
	var env_1 = environment_templates[env_type].instantiate()
	add_child(env_1)
	var env_2 = environment_templates[env_type].instantiate()
	add_child(env_2)
	env_2.translate(Vector3(environment_length, 0, 0))
	environment_position += environment_length * 2

func _process(delta):
	translate(Vector3(delta * -environment_speed, 0, 0))
	environment_position += delta * -environment_speed
	if (position.x < -environment_length):
		translate(Vector3(environment_length, 0, 0))
		environment_position += environment_length
