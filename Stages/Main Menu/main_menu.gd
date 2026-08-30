extends Control



const BUTTTON_MOUSEOVER_CURSOR = preload("uid://cn1s3xrc12r11")
@export_file("*.tscn") var gamePath: String

@onready var main = $Main
@onready var settings = $Settings
@onready var highScoreLabel = $"Main/MarginContainer/VBoxContainer/Highest Score"
@onready var survivalScoreLabel = $"Main/MarginContainer/VBoxContainer/Survival Time"

var timeString: String
var timeOverflowSeconds: int = 0
var timeOverflowMinutes: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(BUTTTON_MOUSEOVER_CURSOR, Input.CURSOR_ARROW, Vector2(16,16))
	
	var timeScore = GameManager.bestSurvivalScore
	timeOverflowSeconds = int(timeScore) % 60
	timeOverflowMinutes = int(timeScore - timeOverflowSeconds) % 3600
	
	if timeScore < 60:
		timeString = str(int(timeScore)) + "s"
	elif timeScore / 60 < 60:
		timeString = str(int(timeScore / 60)) + "m " + str(timeOverflowSeconds) + "s"
	elif timeScore / 60 > 60:
		timeString = str(int(timeScore / 3600)) + "h " + str(timeOverflowMinutes) + "m " + str(timeOverflowSeconds) + "s"
	
	highScoreLabel.text = "Best Score: " + str(GameManager.highScore)
	survivalScoreLabel.text = "Best Time: " + timeString
	
	
	$"Main/Start Game".pressed.connect(startGame)
	$"Main/Settings".pressed.connect(openSettings)
	$"Main/Credits".pressed.connect(rollCredits)
	$"Main/Quit".pressed.connect(quitGame)
	$Settings/Controls.pressed.connect(openControls)
	$Settings/Back.pressed.connect(exitSettings)
	
	$"Main/Start Game".mouse_entered.connect(onButtonHover)
	$"Main/Settings".mouse_entered.connect(onButtonHover)
	$"Main/Credits".mouse_entered.connect(onButtonHover)
	$"Main/Quit".mouse_entered.connect(onButtonHover)
	
	$"Settings/MarginContainer/VBoxContainer/SFX Container/SFX Volume".drag_ended.connect(onSliderDragEnded)


func startGame() -> void:
	GameManager.playButtonSound()
	call_deferred("loadScene")

func openSettings() -> void:
	GameManager.playButtonSound()
	main.visible = false
	settings.visible = true

func rollCredits() -> void:
	GameManager.playButtonSound()

func quitGame() -> void:
	get_tree().quit()

func openControls() -> void:
	GameManager.playButtonSound()

func exitSettings() -> void:
	GameManager.playButtonSound()
	main.visible = true
	settings.visible = false

func onButtonHover() -> void:
	GameManager.playButtonHoverSound()

func onSliderDragEnded(_value_changed: bool) -> void:
	$VolumeTestSound.play()

func loadScene() -> void:
	if gamePath != "":
		GameManager.startRun()
		get_tree().change_scene_to_file(gamePath)
