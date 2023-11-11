extends Node2D

const invalid_ticket_probability := 0.1
const ticket_files := [preload("res://sprites/ticket_checking/ticket_checking_invalid_ticket.png"),
					   preload("res://sprites/ticket_checking/ticket_checking_valid_ticket.png")]
const hand_files := [preload("res://sprites/ticket_checking/ticket_checking_hand_1.png"), 
					 preload("res://sprites/ticket_checking/ticket_checking_hand_2.png"),
					 preload("res://sprites/ticket_checking/ticket_checking_hand_3.png")]
# if you make 600 divisible by hand_velocity rose is happy :)
const hand_velocity := 4

var hand_sprite: Sprite2D
var ticket_sprite: Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	hand_sprite = get_node("hand")
	ticket_sprite = get_node("ticket")
	_randomize_sprites()
	_animate_ticket()

var ticket_is_valid: bool
func _randomize_sprites():
	var p: float = RandomNumberGenerator.new().randf()
	ticket_is_valid = (p < RandomNumberGenerator.new().randf())
	ticket_sprite.set_texture(ticket_files[1 if ticket_is_valid else 0])
	var hand_index: int = RandomNumberGenerator.new().randi_range(0, 2)
	hand_sprite.set_texture(hand_files[hand_index])
	
	
# create the ticket object and move it down into view
var animation_started := false
var animation_finished := false
var relative_hand_pos := 0
func _animate_ticket():
	hand_sprite.position.y -= 600
	ticket_sprite.position.y -= 600
	relative_hand_pos -= 600
	animation_started = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (animation_started and not animation_finished):
		relative_hand_pos +=  hand_velocity
		hand_sprite.position.y +=  hand_velocity
		ticket_sprite.position.y +=  hand_velocity
		if (relative_hand_pos >= 0):
			animation_finished = true
		
	pass

func _on_quit_pressed():
	get_tree().quit()

func _on_yea_button_pressed():
	if (animation_started):
		if (ticket_is_valid):
			succeed()
		else:
			fail()


func _on_nay_button_pressed():
	if (animation_started):
		if (ticket_is_valid):
			fail()
		else:
			succeed()
	
	
func succeed():
	print("ticket checking: do whatever handoff to show success")
	get_tree().quit()

func fail():
	print("ticket checking: do whatever handoff to communicate failure")
	get_tree().quit()
