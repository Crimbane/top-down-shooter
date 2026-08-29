extends Control


var saveFilePath = "user://highscores.save"
var highScore: int = 0
var survivalScore: int = 0

const BUTTTON_MOUSEOVER_CURSOR = preload("uid://cn1s3xrc12r11")
const GAME_SCENE = preload("res://Stages/Maps/red_dungeon_map.tscn")

@onready var highScoreLabel = $"Button Container/MarginContainer/VBoxContainer/Highest Score"
@onready var survivalScoreLabel = $"Button Container/MarginContainer/VBoxContainer/Survival Time"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(BUTTTON_MOUSEOVER_CURSOR, Input.CURSOR_ARROW, Vector2(16,16))
	loadSaveFile()
	GameManager.highScore = highScore
	GameManager.survivalScore = survivalScore
	
	$"Button Container/Start Game".pressed.connect(startGame)
	$"Button Container/Settings".pressed.connect(openSettings)
	$"Button Container/Credits".pressed.connect(rollCredits)
	$"Button Container/Quit".pressed.connect(quitGame)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	highScoreLabel.text = "Highscore: " + str(highScore)
	survivalScoreLabel.text = "Survival Time: " + str(survivalScore)
	
func startGame() -> void:
	call_deferred("loadScene")

func openSettings() -> void:
	pass

func rollCredits() -> void:
	pass

func quitGame() -> void:
	get_tree().quit()

func loadScene() -> void:
	if GAME_SCENE.resource_path != "":
		get_tree().change_scene_to_packed(GAME_SCENE)

func loadSaveFile() -> void:
	if FileAccess.file_exists(saveFilePath):
		var file = FileAccess.open(saveFilePath, FileAccess.READ)
		highScore = file.get_var()
		survivalScore = file.get_var()
