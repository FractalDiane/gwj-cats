extends Minigame

###########################################################################################
### special taskDone return: data=1 if player overfilled boiler and exploded themselves ###
###########################################################################################

var overlay_textures: Array[Texture2D] = [
	preload("res://sprites/coal game/overlay_closed.png"),
	preload("res://sprites/coal game/overlay_open.png")
]
var scoop_textures: Array[Texture2D] = [
	preload("res://sprites/coal game/shovel.png"),
	preload("res://sprites/coal game/shovel_coal.png")
]
var coalPrefab: PackedScene = preload("res://prefabs/coal.tscn")

# var taskDone: bool

@export var coalNeeded: int
@export var coalToExplode: int
@export var coalPerScoop: int
@export var coalSpread: int
@export var coalSpeed: float
@export var coalFlingMaxSpeed: float
@export var coalFlingSpeedVariance: float
@export var coalFlingAngleVariance: float
@export var coalFlingTorqueVariance: float

var coalAmount : int
var hasCoal: bool
var hatchOpen : bool
var mouse_pos: Vector2
var random: RandomNumberGenerator

var coalPieces: Array[RigidBody2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	coalAmount = 0
	hasCoal = false
	hatchOpen = false
	
	random = RandomNumberGenerator.new()
	
	coalPieces = []
	
	$debugtext.text = "coal: 0 of " + str(coalNeeded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# move scoop to mouse pos
	mouse_pos = get_viewport().get_mouse_position()
	$scoop.position = mouse_pos
	
	# drop coal if leftMouseUp
	if (Input.is_action_just_released("input_click")):
		hasCoal = false
		#$scoop.texture = scoop_textures[0]
		
		for coal in coalPieces:
			if (coal == null):
				continue
			var new_magnitude: float = min(coal.linear_velocity.length(), coalFlingMaxSpeed)
			coal.linear_velocity = (coal.linear_velocity.normalized().rotated(coalFlingAngleVariance * random.randf()) * new_magnitude * ((1+coalFlingSpeedVariance) * random.randf()))
			
			coal.apply_torque_impulse(coalFlingTorqueVariance * random.randf())
		coalPieces = []


func _physics_process(delta):
	for i in range(len(coalPieces)):
		if (coalPieces[i] == null):
			continue
		var angle: float = 2 * PI * (float(i) / len(coalPieces))
		var goal_pos: Vector2 = mouse_pos + Vector2(cos(angle) * coalSpread, sin(angle) * coalSpread)
		coalPieces[i].linear_velocity = (goal_pos - coalPieces[i].position) * coalSpeed


func _on_coal_button_pressed():
	hasCoal = true
	#$scoop.texture = scoop_textures[1]
	
	for i in range(coalPerScoop):
		var coal := coalPrefab.instantiate() as RigidBody2D
		coalPieces.append(coal)
		self.add_child(coal)
		
		var angle: float = (2.0 * PI) * (float(i) / coalPerScoop)
		var offset: Vector2 = Vector2(coalSpread * cos(angle), coalSpread * sin(angle))
		coal.position = mouse_pos + offset
		
		coal.rotation = (2 * PI) * random.randf()


func _on_lever_button_pressed():
	hatchOpen = !hatchOpen
	$overlay.texture = overlay_textures[1 if hatchOpen else 0]
	
	$lever_button.disabled = hatchOpen
	$lever_button_alt.disabled = !hatchOpen
	
	if (coalAmount >= coalNeeded):
		$debugtext.text = "task done ! (return task successful)"
		minigame_done.emit(true, 0)


func _on_furnace_trigger_entered(body: Node2D):
	if (hatchOpen):
		if (coalAmount < coalToExplode):
			coalAmount += 1
		$debugtext.text = "coal: " + str(coalAmount) + " of " + str(coalNeeded)
		
		if (coalAmount == coalToExplode):
			$debugtext.text = "get exploded idiot (return task fail/set death flag or something)"
			minigame_done.emit(false, 1)
			
			coalAmount = coalToExplode + 5 # jank bs to prevent minigame_done from being emitted twice in a row
		
		body.queue_free()
		# _on_coal_button_pressed()

