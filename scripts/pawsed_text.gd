extends Node2D

@onready var cloudanim: AnimatedSprite2D = $cloud
@onready var textanim: AnimatedSprite2D = $text

func _ready():
	cloudanim.play("default")
	textanim.play("default")
