extends Minigame

const lever_textures := [preload("res://sprites/train_control_minigame/train_control_unlocked.png"),
						 preload("res://sprites/train_control_minigame/train_control_locked.png"),
						 preload("res://sprites/train_control_minigame/train_control_locked.png"),
						preload("res://sprites/train_control_minigame/train_control_locked.png")]

enum LeverState {unlocked, locked_left, locked_right, undetermined}
var lever_state := LeverState.undetermined

# TODO: upon closing, query the lever's position by reading this variable
#       if unlocked or indeterminate, flip a coin
var lever_sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	lever_sprite = get_node("lever")
	# TODO: make this an input parameter to the minigame
	#       (must be either locked_left or locked_right)
	var initial_state: LeverState = LeverState.locked_left
	lever_state = initial_state
	lever_sprite.rotation = -3*PI/4 if lever_state == LeverState.locked_left else -PI/4
	lever_sprite.set_texture(lever_textures[lever_state])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (lever_state == LeverState.unlocked):
		# hjskghjkf
		var mouse_pos := get_global_mouse_position()
		var pivot_point_node := get_node("lever_pivot_point")
		var pivot_point: Vector2 = pivot_point_node.position
		
		# angle on unit circle relative to pivot point
		var dx := mouse_pos.x - pivot_point.x
		var dy := mouse_pos.y - pivot_point.y
		var mouse_angle = -atan2(dy, dx)
		if (mouse_angle > 3*PI/4 or mouse_angle < PI/4):
			return
			
		# orient the lever
		var lever_height = lever_textures[0].get_height()
		var lever_width = lever_textures[0].get_height()
		lever_sprite = get_node("lever")
		lever_sprite.rotation = -mouse_angle
		


func _on_lever_right_button_pressed():
	if (lever_state == LeverState.unlocked):
		lever_state = LeverState.locked_right
		lever_sprite.set_texture(lever_textures[lever_state])
	elif (lever_state == LeverState.locked_right):
		lever_state = LeverState.unlocked
		lever_sprite.set_texture(lever_textures[lever_state])


func _on_lever_left_button_pressed():
	if (lever_state == LeverState.unlocked):
		lever_state = LeverState.locked_left
		lever_sprite.set_texture(lever_textures[lever_state])
	elif (lever_state == LeverState.locked_left):
		lever_state = LeverState.unlocked
		lever_sprite.set_texture(lever_textures[lever_state])



func exit_task():
	# on task exit, return 2 for lever left, 3 for lever right, or coin flip if unlocked
	if (lever_state == LeverState.locked_left or lever_state == LeverState.locked_right):
		minigame_done.emit(true, int(lever_state + 1))
	else:
		var p: float = RandomNumberGenerator.new().randf()
		minigame_done.emit(true, 2 if (p < 0.5) else 3)


func early_return_requested():
	# on current lever state requested before end of minigame, return 2 for lever left, 3 for lever right, or coin flip if unlocked
	if (lever_state == LeverState.locked_left or lever_state == LeverState.locked_right):
		early_return_send.emit(true, int(lever_state + 1))
	else:
		var p: float = RandomNumberGenerator.new().randf()
		early_return_send.emit(true, 2 if (p < 0.5) else 3)
