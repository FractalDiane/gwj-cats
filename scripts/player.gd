class_name Player
extends CharacterBody3D

@export var camera: PlayerCamera = null

const SPEED := 2.5
#const JUMP_VELOCITY := 4.5

@onready var interaction_component := $InteractionActivatorComponent as InteractionActivatorComponent

#var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"debug_left"):
		camera.move_car(PlayerCamera.Direction.Left)
	elif Input.is_action_just_pressed(&"debug_right"):
		camera.move_car(PlayerCamera.Direction.Right)
		
	if Input.is_action_just_pressed("interact"):
		interaction_component.try_interact()


func _physics_process(delta: float) -> void:
	#if not is_on_floor():
	#	velocity.y -= gravity * delta

	#if Input.is_action_just_pressed("move_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
