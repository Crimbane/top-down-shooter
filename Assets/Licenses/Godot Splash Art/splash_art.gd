extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation_finished.connect(loadMainMenu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func loadMainMenu() -> void:
	call_deferred("loadScene")

func loadScene() -> void:
	get_tree().change_scene_to_file("uid://cmb2as5hd36lj")
