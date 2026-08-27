extends Node

const BUTTTON_MOUSEOVER_CURSOR = preload("uid://cn1s3xrc12r11")

func _ready() -> void:
	Input.set_custom_mouse_cursor(BUTTTON_MOUSEOVER_CURSOR, Input.CURSOR_POINTING_HAND, Vector2(16,16))
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
			pass
			#get_tree().quit()
