extends CanvasLayer

@onready var hud_root := $HUD as Control
@onready var task_text := $taskText as RichTextLabel

func add_hud_child(what: Node) -> void:
	hud_root.add_child(what)
