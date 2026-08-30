extends Node

const BUTTTON_MOUSEOVER_CURSOR = preload("uid://cn1s3xrc12r11")
const DIFFICULTY_CIRCLE = preload("uid://dyn6yts7bmn7b")


var score: int = 0
var highScore: int = 0

var survivalScore: float = 0.0
var bestSurvivalScore: float = 0.0

var survivalActive: bool = false

var difficultyMultiplier: float = 1.0
var difficultyTimerInterval: float = 10.0
var difficultyLevel: int = 0

const SAVE_PATH = "user://savegame.json"


func _ready() -> void:
	Input.set_custom_mouse_cursor(BUTTTON_MOUSEOVER_CURSOR, Input.CURSOR_POINTING_HAND, Vector2(16,16))
	print(ProjectSettings.globalize_path(SAVE_PATH))
	loadSaveFile()


func _process(delta: float) -> void:
	if survivalActive:
		survivalScore += delta
		updateDifficulty()
	

func playButtonSound() -> void:
	$"Button Sound".play()

func playButtonHoverSound() -> void:
	$"ButtonHover Sound".play()

func playPickupSound() -> void:
	$"Pickup Sound".play()


func increaseScore(amount: int) -> void:
	score += amount


func updateDifficulty() -> void:
	if survivalScore > difficultyTimerInterval * 12 and difficultyLevel < 7:
		difficultyMultiplier = 3.0
		difficultyLevel = 7
		$"Difficulty Increase Sound".play()
		playDifficultyEffect()
	elif survivalScore > difficultyTimerInterval * 6 and difficultyLevel < 6:
		difficultyMultiplier = 2.2
		difficultyLevel = 6
		$"Difficulty Increase Sound".play()
		playDifficultyEffect()
	elif survivalScore > difficultyTimerInterval * 5 and difficultyLevel < 5:
		difficultyMultiplier = 2.0
		difficultyLevel = 5
		$"Difficulty Increase Sound".play()
		playDifficultyEffect()
	elif survivalScore > difficultyTimerInterval * 4 and difficultyLevel < 4:
		difficultyMultiplier = 1.8
		difficultyLevel = 4
		$"Difficulty Increase Sound".play()
		playDifficultyEffect()
	elif survivalScore > difficultyTimerInterval * 3 and difficultyLevel < 3:
		difficultyMultiplier = 1.6
		difficultyLevel = 3
		$"Difficulty Increase Sound".play()
		playDifficultyEffect()
	elif survivalScore > difficultyTimerInterval * 2 and difficultyLevel < 2:
		difficultyMultiplier = 1.4
		difficultyLevel = 2
		$"Difficulty Increase Sound".play()
		playDifficultyEffect()
	elif survivalScore > difficultyTimerInterval and difficultyLevel < 1:
		difficultyMultiplier = 1.2
		difficultyLevel = 1
		$"Difficulty Increase Sound".play()
		playDifficultyEffect()

func playDifficultyEffect() -> void:
	var center = get_tree().current_scene.get_node("%Map Center Marker2D")
	
	var circle = DIFFICULTY_CIRCLE.instantiate()
	get_tree().current_scene.add_child(circle)
	
	circle.global_position = center.global_position
	circle.playEffect()

func startRun() -> void:
	score = 0
	survivalScore = 0.0
	survivalActive = true
	difficultyMultiplier = 1.0


func endRun() -> void:
	survivalActive = false
	difficultyMultiplier = 1.0
	
	if score > highScore:
		highScore = score
	
	if survivalScore > bestSurvivalScore:
		bestSurvivalScore = survivalScore
	
	saveGame()
	
	score = 0
	survivalScore = 0.0


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
