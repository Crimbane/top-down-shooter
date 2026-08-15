extends CharacterBody2D

signal hit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	hit.connect(onHit)

func _process(_delta: float) -> void:
	if velocity.x > 0 or Input.is_action_pressed("Move Right"):
		$AnimatedSprite2D.animation = "right"
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0 or Input.is_action_pressed("Move Left"):
		$AnimatedSprite2D.animation = "left"
		$AnimatedSprite2D.flip_h = false
	elif velocity.y < 0 or Input.is_action_pressed("Move Up"):
		$AnimatedSprite2D.animation = "up"
	elif velocity.y < 0 or Input.is_action_pressed("Move Down"):
		$AnimatedSprite2D.animation = "down"

func _physics_process(_delta: float) -> void:

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

func onHit() -> void:
	call_deferred("restartGame")

func restartGame() -> void:
	get_tree().reload_current_scene()
