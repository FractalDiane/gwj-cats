extends TrainCar

@export var anim: AnimationPlayer
@export var fade_time: float = 1.5

func _ready():
	while available_minigames.size() > 2:
		var i = randi_range(0, available_minigames.size()-1)
		#n.get_parent().remove_child(n)
		available_minigames[i].queue_free()
		available_minigames.remove_at(i)
