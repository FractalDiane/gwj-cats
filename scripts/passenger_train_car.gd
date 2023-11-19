extends TrainCar

@export var anim: AnimationPlayer
@export var fade_time: float = 1.5
@export var passenger_possibilities: Array

func _ready():
	for i in range(2):
		var p = get_node(passenger_possibilities.pick_random())
		p.set_process(true)
		p.set_visible(true)
