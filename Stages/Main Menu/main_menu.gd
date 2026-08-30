extends Control


var saveFilePath = "user://highscores.save"
var highScore: int
var bestSurvivalScore: int

const BUTTTON_MOUSEOVER_CURSOR = preload("uid://cn1s3xrc12r11")
@export_file("*.tscn") var gamePath: String

@onready var highScoreLabel = $"Button Container/MarginContainer/VBoxContainer/Highest Score"
@onready var survivalScoreLabel = $"Button Container/MarginContainer/VBoxContainer/Survival Time"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(BUTTTON_MOUSEOVER_CURSOR, Input.CURSOR_ARROW, Vector2(16,16))
	#loadSaveFile()
	
	highScore = GameManager.highScore
	bestSurvivalScore = GameManager.bestSurvivalScore
	
	
	$"Button Container/Start Game".pressed.connect(startGame)
	$"Button Container/Settings".pressed.connect(openSettings)
	$"Button Container/Credits".pressed.connect(rollCredits)
	$"Button Container/Quit".pressed.connect(quitGame)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	highScoreLabel.text = "Highscore: " + str(highScore)
	survivalScoreLabel.text = "Survival Time: " + str(bestSurvivalScore)
	
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

func loadSaveFile() -> void:
	if FileAccess.file_exists(saveFilePath):
		var file = FileAccess.open(saveFilePath, FileAccess.READ)
		highScore = file.get_var()
		bestSurvivalScore = file.get_var()
		
		#file.store_var(highScore)
