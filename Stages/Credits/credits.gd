extends Control

@onready var creditsText: Label = $"Made by"
@onready var returnText: Label = $"Return Text"
var tweenFinished = false

func _ready() -> void:
	var screenSize = get_viewport_rect().size
	
	var target = creditsText.position.y
	creditsText.position.y = screenSize.y


	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(creditsText, "position:y", target + -50, 4.0)
	await tween.finished
	returnText.visible = true
	tweenFinished = true

func _process(_delta) -> void:
	if tweenFinished and Input.is_anything_pressed():
		loadMainMenu()

func loadMainMenu() -> void:
	GameManager.playButtonSound()
	MusicManager.normalPitchMusicPlayer()
	MusicManager.stopMusic()
	call_deferred("loadScene")

func loadScene() -> void:
	get_tree().change_scene_to_file("uid://cmb2as5hd36lj")
