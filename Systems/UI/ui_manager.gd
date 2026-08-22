extends Control

var cursorTexture = load("uid://cy2ue5555y0r7")

@onready var hearts = $"HUD/MarginContainer Top Bar/HBox Hearts"
@onready var player = get_tree().get_first_node_in_group("Player")

@onready var actionProgress = $"HUD/Action Progress"
@onready var actionProgress2 = $"HUD/Bottom Left/VBox/HBox Bullet/Action Progress 2"
@onready var actionProgress3 = $"HUD/Bottom Left/VBox/HBox Bullet Alt/Action Progress 3"
var actionTween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Dev/Quit Button".pressed.connect(exitGame)
	$"Dev/Restart Button".pressed.connect(restartScene)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Resume Button".pressed.connect(resumeGame)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Quit Button".pressed.connect(exitGame)
	player.healthChanged.connect(updateHearts)
	
	call_deferred("updateHearts")
	
	#resizeCursor()

func _process(_delta: float) -> void:
	var mousePosition = get_global_mouse_position()
	actionProgress.global_position = mousePosition + Vector2(5,5)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		pauseGame()

func exitGame() -> void:
	get_tree().quit()

func restartScene() -> void:
	get_tree().reload_current_scene()

func pauseGame() -> void:
	$"Pause Menu".visible = true
	get_tree().paused = true

func resumeGame() -> void:
	get_tree().paused = false
	$"Pause Menu".visible = false

func updateHearts(currentHealth: int = player.currentHealth) -> void:
	for i in range(hearts.get_child_count()):
		var heart = hearts.get_child(i)
		
		if i < player.currentHealth:
			heart.texture = preload("uid://c6xveg6xhk0jj")
		else:
			heart.texture = preload("uid://dbbjbcueyg57m")



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


func resizeCursor() -> void:
	var image = cursorTexture.get_image()
	image.resize(32, 32, Image.INTERPOLATE_NEAREST)
	
	var texture = ImageTexture.create_from_image(image)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2(16, 16))
