extends Node

const BUTTTON_MOUSEOVER_CURSOR = preload("uid://cn1s3xrc12r11")

var score: int = 0
var highScore: int = 0

var survivalScore: float = 0.0
var bestSurvivalScore: float = 0.0

var survivalActive: bool = false

const SAVE_PATH = "user://savegame.json"


func _ready() -> void:
	Input.set_custom_mouse_cursor(BUTTTON_MOUSEOVER_CURSOR, Input.CURSOR_POINTING_HAND, Vector2(16,16))
	print(ProjectSettings.globalize_path(SAVE_PATH))
	loadSaveFile()


func _process(delta: float) -> void:
	if survivalActive:
		survivalScore += delta
	

func playButtonSound() -> void:
	$"Button Sound".play()


func increaseScore(amount: int) -> void:
	score += amount


func startRun() -> void:
	score = 0
	survivalScore = 0.0
	survivalActive = true


func endRun() -> void:
	survivalActive = false
	
	if score > highScore:
		highScore = score
	
	if survivalScore > bestSurvivalScore:
		bestSurvivalScore = survivalScore
	
	saveGame()


func resetScore() -> void: # can put in settings
	survivalActive = false
	score = 0
	highScore = 0
	
	survivalScore = 0.0
	bestSurvivalScore = 0.0
	
	saveGame()


func saveGame() -> void:
	var saveData = {
		"highScore": highScore,
		"bestSurvivalScore": bestSurvivalScore
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()


func loadSaveFile() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file:
		var saveData = JSON.parse_string(file.get_as_text())
		file.close()
		
		if saveData is Dictionary:
			highScore = saveData.get("highScore", 0)
			bestSurvivalScore = saveData.get("bestSurvivalScore", 0.0)
