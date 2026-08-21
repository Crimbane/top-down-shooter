extends Control

var cursorTexture

@onready var cursor: Sprite2D = $"Software Mouse/Cursor"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide native mouse
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	$"Dev/Quit Button".pressed.connect(exitGame)
	$"Dev/Restart Button".pressed.connect(restartScene)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Resume Button".pressed.connect(resumeGame)
	$"Pause Menu/CenterContainer/PanelContainer/VBoxContainer/Quit Button".pressed.connect(exitGame)

func _process(_delta: float) -> void:
	var mousePosition = get_global_mouse_position()
	cursor.position = mousePosition
	$"HUD/Ammo Counter".position = mousePosition + Vector2 (-19, -7.5)
	$"HUD/Ammo Counter Alt".position = mousePosition + Vector2 (10,-7.5)

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

func resizeCursor() -> void:
	var image = cursorTexture.get_image()
	image.resize(16, 16)
	
	var texture = ImageTexture.create_from_image(image)
	Input.set_custom_mouse_cursor(texture)
