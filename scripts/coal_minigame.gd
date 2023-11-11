extends Node2D

var overlay_textures: Array[Texture2D] = [
	preload("res://sprites/coal game/overlay_closed.png"),
	preload("res://sprites/coal game/overlay_open.png")
]
var scoop_textures: Array[Texture2D] = [
	preload("res://sprites/coal game/shovel.png"),
	preload("res://sprites/coal game/shovel_coal.png")
]

var taskDone: bool

@export var coalNeeded: int

var coalAmount : int
var hasCoal: bool
var hatchOpen : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	taskDone = false
	coalAmount = 0
	hasCoal = false
	hatchOpen = false
	
	$debugtext.text = "coal: 0 of " + str(coalNeeded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# move scoop to mouse pos
	var pos: Vector2 = get_viewport().get_mouse_position()
	
	$scoop.set_global_position(pos)


func _on_coal_button_pressed():
	hasCoal = !hasCoal
	$scoop.texture = scoop_textures[1 if hasCoal else 0]


func _on_lever_button_pressed():
	hatchOpen = !hatchOpen
	$overlay.texture = overlay_textures[1 if hatchOpen else 0]
	
	$lever_button.disabled = hatchOpen
	$lever_button_alt.disabled = !hatchOpen
	
	if (coalAmount >= coalNeeded and !taskDone):
		taskDone = true
		print("task done !")


func _on_furnace_button_pressed():
	if (hatchOpen and hasCoal):
		if (coalAmount < coalNeeded):
			coalAmount += 1
		$debugtext.text = "coal: " + str(coalAmount) + " of " + str(coalNeeded)
		
		_on_coal_button_pressed()
