class_name Player
extends CharacterBody3D

@export var camera: PlayerCamera = null

const SPEED := 2.5
#const JUMP_VELOCITY := 4.5

@onready var interaction_component := $InteractionActivatorComponent as InteractionActivatorComponent

var block_movement := false

#var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	camera.move_started.connect(_on_camera_move_started)
	camera.move_finished.connect(_on_camera_move_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"debug_left"):
		camera.move_car(PlayerCamera.Direction.Left, self)
	elif Input.is_action_just_pressed(&"debug_right"):
		camera.move_car(PlayerCamera.Direction.Right, self)
		
	if Input.is_action_just_pressed("interact"):
		interaction_component.try_interact()


func _physics_process(delta: float) -> void:
	#if not is_on_floor():
	#	velocity.y -= gravity * delta

	#if Input.is_action_just_pressed("move_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	if not block_movement:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()


func _on_camera_move_started() -> void:
	block_movement = true
	

func _on_camera_move_finished() -> void:
	block_movement = false
