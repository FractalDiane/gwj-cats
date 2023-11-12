extends CanvasLayer

@onready var hud_root := $HUD as Control

func add_hud_child(what: Node) -> void:
	hud_root.add_child(what)
