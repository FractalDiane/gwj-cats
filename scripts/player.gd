class_name Player
extends CharacterBody3D

signal jump_point_exited()

@export var camera: PlayerCamera = null

const SPEED := 2.5

@onready var ground_position := $GroundPosition as Marker3D
@onready var interaction_component := $InteractionActivatorComponent as InteractionActivatorComponent

var block_movement := false
var on_jump_point := false
var pre_jump_location := Vector3()

# ==================================================================================================

func _ready():
	camera.move_started.connect(_on_camera_move_started)
	camera.move_finished.connect(_on_camera_move_finished)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"debug_left"):
		camera.move_car(PlayerCamera.Direction.Left, self)
	elif Input.is_action_just_pressed(&"debug_right"):
		camera.move_car(PlayerCamera.Direction.Right, self)
		
	if Input.is_action_just_pressed("interact"):
		interaction_component.try_interact(self)


func _physics_process(delta: float) -> void:
	if not block_movement:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction = (camera.transform.basis * Vector3(input_dir.x, -input_dir.y, 0)).normalized()
		if direction:
			if not on_jump_point:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
				
				var my_quat := transform.basis.get_rotation_quaternion()
				var target_quat := Quaternion(Vector3(0, 1, 0), atan2(direction.x, -direction.y))
				quaternion = my_quat.slerp(target_quat, delta * 10.0)
			else:
				jump_to_jump_point(null, true)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

# ==================================================================================================

func jump_to_jump_point(jump_point: JumpPoint, jump_away: bool) -> void:
	var target := jump_point.global_position if not jump_away else pre_jump_location
	look_at(target)
	rotation.y += PI
	
	if not jump_away:
		pre_jump_location = position
	
	var tween_xz := create_tween()
	tween_xz.set_parallel(true)
	tween_xz.tween_property(self, ^"position:x", target.x, 0.5)
	tween_xz.tween_property(self, ^"position:z", target.z, 0.5)
	
	var y_add := ground_position.position.y if not jump_away else 0.0
	var tween_y := create_tween()
	tween_y.tween_property(self, ^"position:y", target.y + 0.5 - ground_position.position.y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, ^"position:y", target.y - y_add, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	block_movement = true
	tween_xz.finished.connect(_on_jump_finished.bind(jump_away))

# ==================================================================================================

func _on_camera_move_started() -> void:
	block_movement = true
	

func _on_camera_move_finished() -> void:
	block_movement = false
	
	
func _on_jump_finished(ending_jump: bool) -> void:
	block_movement = false
	on_jump_point = not ending_jump
	if ending_jump:
		jump_point_exited.emit()
