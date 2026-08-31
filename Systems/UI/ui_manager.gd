extends Control


const ARROW_CURSOR = preload("res://Systems/UI/Art/Crosshair-resized-ps.png")
@export_file("*.tscn") var mainMenuPath: String
@export_file("*.tscn") var dungeonPath: String

var cursorTexture = load("uid://cy2ue5555y0r7")

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var hearts = $"HUD/MarginContainer Top Bar/HBox Hearts"

@onready var actionProgress = $"HUD/Action Progress"
@onready var actionProgress2 = $"HUD/Bottom Left/VBox/HBox Bullet/Action Progress 2"
@onready var actionProgress3 = $"HUD/Bottom Left/VBox/HBox Bullet Alt/Action Progress 3"
var actionTween: Tween

@onready var damageBuff: TextureProgressBar = $"HUD/Top Middle Bar/HBox Buffs/Damage/Timer Bar"
@onready var shieldBuff: TextureProgressBar = $"HUD/Top Middle Bar/HBox Buffs/Shield/Timer Bar"
@onready var speedBuff: TextureProgressBar = $"HUD/Top Middle Bar/HBox Buffs/Speed/Timer Bar"
@onready var fireRateBuff: TextureProgressBar = $"HUD/Top Middle Bar/HBox Buffs/FireRate/Timer Bar"

@onready var scoreLabel: Label = $"Death Screen/VBoxContainer/Scoring/VBoxContainer/Score"
@onready var timeScoreLabel: Label = $"Death Screen/VBoxContainer/Scoring/VBoxContainer/Survival Score"
@onready var highScoreLabel: Label = $"Death Screen/VBoxContainer/Scoring/VBoxContainer/MarginContainer/VBoxContainer/Highscore"
@onready var bestTimeScoreLabel: Label = $"Death Screen/VBoxContainer/Scoring/VBoxContainer/MarginContainer/VBoxContainer/Best Survival Score"

@onready var devDifficultyLabel: Label = $Dev/Difficulty
@onready var devScoreLabel: Label = $Dev/Score




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(ARROW_CURSOR, Input.CURSOR_ARROW, Vector2(16,16))
	
	$"Dev/Quit Button".pressed.connect(exitGame)
	$"Dev/Restart Button".pressed.connect(restartScene)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Resume Button".pressed.connect(resumeGame)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Main Menu Button".pressed.connect(mainMenu)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Quit Button".pressed.connect(exitGame)
	$"Death Screen/VBoxContainer/Death Try Again Button".pressed.connect(tryAgain)
	$"Death Screen/VBoxContainer/Death Main Menu Button".pressed.connect(mainMenu)
	$"Death Screen/VBoxContainer/Death Quit Button".pressed.connect(exitGame)
	
	$"Dev/Quit Button".mouse_entered.connect(onButtonHover)
	$"Dev/Restart Button".mouse_entered.connect(onButtonHover)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Resume Button".mouse_entered.connect(onButtonHover)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Main Menu Button".mouse_entered.connect(onButtonHover)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Quit Button".mouse_entered.connect(onButtonHover)
	$"Death Screen/VBoxContainer/Death Try Again Button".mouse_entered.connect(onButtonHover)
	$"Death Screen/VBoxContainer/Death Main Menu Button".mouse_entered.connect(onButtonHover)
	$"Death Screen/VBoxContainer/Death Quit Button".mouse_entered.connect(onButtonHover)
	
	player.healthChanged.connect(updateHearts)
	
	$"Death Screen".visible = false
	
	damageBuff.value = 0
	speedBuff.value = 0
	shieldBuff.value = 0
	fireRateBuff.value = 0
	
	
	call_deferred("updateHearts")
	#resizeCursor()


func _process(_delta: float) -> void:
	var mousePosition = get_global_mouse_position()
	actionProgress.global_position = mousePosition + Vector2(5,5)
	
	updateBuffTimer(damageBuff, player.get_node("Timers/Damage Buff Timer"))
	updateBuffTimer(speedBuff, player.get_node("Timers/Speed Buff Timer"))
	updateBuffTimer(shieldBuff, player.get_node("Timers/Shield Buff Timer"))
	updateBuffTimer(fireRateBuff, player.get_node("Timers/Fire Rate Buff Timer"))
	
	devDifficultyLabel.text = "Difficulty: " + str(GameManager.difficultyMultiplier)
	devScoreLabel.text = "Score: " + str(GameManager.score)
	#showScore()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		pauseGame()


func exitGame() -> void:
	get_tree().quit()


func restartScene() -> void:
	get_tree().reload_current_scene()


func pauseGame() -> void:
	$"Pause Menu".visible = true
	GameManager.pauseRun()
	get_tree().paused = true


func mainMenu() -> void:
	GameManager.playButtonSound()
	MusicManager.normalPitchMusicPlayer()
	MusicManager.stopMusic()
	get_tree().paused = false
	call_deferred("loadScene")


func resumeGame() -> void:
	get_tree().paused = false
	GameManager.playButtonSound()
	$"Pause Menu".visible = false
	GameManager.unPauseRun()


func onButtonHover() -> void:
	GameManager.playButtonHoverSound()


func loadScene() -> void:
	if mainMenuPath != "":
		get_tree().paused = false
		GameManager.endRun()
		get_tree().change_scene_to_file(mainMenuPath)


func tryAgain() -> void:
	GameManager.playButtonSound()
	if dungeonPath != "":
		get_tree().paused = false
		GameManager.startRun()
		get_tree().change_scene_to_file(dungeonPath)


func showScore() -> void:
	GameManager.endRun()
	$"Death Screen".visible = true
	$HUD.visible = false
	get_tree().paused = true
	
	
	scoreLabel.text = "Score: " + str(GameManager.score)
	timeScoreLabel.text = "Time: " + timeUnitBreakdown(GameManager.survivalScore)
	
	highScoreLabel.text = "Highscore: " + str(GameManager.highScore)
	bestTimeScoreLabel.text = "Best Time: " + timeUnitBreakdown(GameManager.bestSurvivalScore)

func timeUnitBreakdown(timeScore: float) -> String:
	var timeString: String
	var timeOverflowSeconds = int(timeScore) % 60
	var timeOverflowMinutes = int(timeScore - timeOverflowSeconds) % 3600
	
	if timeScore < 60:
		timeString = str(int(timeScore)) + "s"
	elif timeScore / 60 < 60:
		timeString = str(int(timeScore / 60)) + "m " + str(timeOverflowSeconds) + "s"
	elif timeScore / 60 > 60:
		timeString = str(int(timeScore / 3600)) + "h " + str(timeOverflowMinutes) + "m " + str(timeOverflowSeconds) + "s"
	
	return timeString

func updateHearts(currentHealth: int = player.currentHealth) -> void:
	for i in range(hearts.get_child_count()):
		var heart = hearts.get_child(i)
		
		if i < player.currentHealth:
			heart.texture = preload("uid://bhotegj5c7q4b") #full heart
		else:
			heart.texture = preload("uid://buyokg05s2wqc") #empty heart


func updateActiveBullet(usingAltBullet: bool) -> void:
	$"HUD/Bottom Left/VBox/HBox Bullet".visible = not usingAltBullet
	$"HUD/Bottom Left/VBox/HBox Bullet Alt".visible = usingAltBullet


func startActionProgress(reloadTime: float) -> void:
	actionProgress.value = 0
	actionProgress2.value = 0
	actionProgress3.value = 0
	
	actionProgress.visible = true
	actionProgress2.visible = true
	actionProgress3.visible = true
	
	if actionTween:
		actionTween.kill()
	
	actionTween = create_tween()
	actionTween.set_parallel(true)#
	actionTween.tween_property(actionProgress, "value", 100.0, reloadTime)
	actionTween.tween_property(actionProgress2, "value", 100.0, reloadTime)
	actionTween.tween_property(actionProgress3, "value", 100.0, reloadTime)
	
	await actionTween.finished
	actionProgress.visible = false
	actionProgress2.visible = false
	actionProgress3.visible = false


func updateBuffTimer(buffIcon: TextureProgressBar, timer: Timer) -> void:
	if timer.is_stopped():
		buffIcon.value = 0
	else:
		buffIcon.value = (timer.time_left / timer.wait_time) * 100.0


func resizeCursor() -> void:
	var image = cursorTexture.get_image()
	image.resize(32, 32, Image.INTERPOLATE_NEAREST)
	
	var texture = ImageTexture.create_from_image(image)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2(16, 16))
