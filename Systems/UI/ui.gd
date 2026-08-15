extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Quit Button".pressed.connect(exitGame)
	$"Restart Button".pressed.connect(restartScene)


func exitGame() -> void:
	get_tree().quit()

func restartScene() -> void:
	get_tree().reload_current_scene()
