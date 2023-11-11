extends Control

@export var mmenu: Control
@export var omenu: Control

@export var fullToggle: CheckButton
@export var musicSlider: HSlider
@export var soundSlider: HSlider

var musicBusIndex: int
var soundBusIndex: int

func _ready():
	musicBusIndex = AudioServer.get_bus_index("Music")
	soundBusIndex = AudioServer.get_bus_index("SFX")
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullToggle.button_pressed = true
	else:
		fullToggle.button_pressed = false
	musicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(musicBusIndex))
	soundSlider.value = db_to_linear(AudioServer.get_bus_volume_db(soundBusIndex))

func _on_quit_button_pressed():
	get_tree().quit()

func _on_play_button_pressed():
	pass # Replace with function body.

func _on_options_button_pressed():
	mmenu.visible = false
	omenu.visible = true

func _on_check_button_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(musicBusIndex, linear_to_db(value))

func _on_sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(soundBusIndex, linear_to_db(value))

func _on_back_button_pressed():
	mmenu.visible = true
	omenu.visible = false
