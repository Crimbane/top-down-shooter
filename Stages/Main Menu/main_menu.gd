extends Control



const BUTTTON_MOUSEOVER_CURSOR = preload("uid://cn1s3xrc12r11")
@export_file("*.tscn") var gamePath: String

@onready var highScoreLabel = $"Button Container/MarginContainer/VBoxContainer/Highest Score"
@onready var survivalScoreLabel = $"Button Container/MarginContainer/VBoxContainer/Survival Time"

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
	
	
	$"Button Container/Start Game".pressed.connect(startGame)
	$"Button Container/Settings".pressed.connect(openSettings)
	$"Button Container/Credits".pressed.connect(rollCredits)
	$"Button Container/Quit".pressed.connect(quitGame)


func startGame() -> void:
	GameManager.playButtonSound()
	call_deferred("loadScene")

func openSettings() -> void:
	GameManager.playButtonSound()

func rollCredits() -> void:
	GameManager.playButtonSound()

func quitGame() -> void:
	get_tree().quit()

func loadScene() -> void:
	if gamePath != "":
		GameManager.startRun()
		get_tree().change_scene_to_file(gamePath)
