extends CharacterBody2D

signal hit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var idle_direction: String = "down"

func _ready() -> void:
	hit.connect(onHit)

func _process(_delta: float) -> void:
	if velocity.x > 0 or Input.is_action_pressed("Move Right"):
		$AnimatedSprite2D.play("right")
		$AnimatedSprite2D.flip_h = true
		idle_direction = "right"
	elif velocity.x < 0 or Input.is_action_pressed("Move Left"):
		$AnimatedSprite2D.play("left")
		$AnimatedSprite2D.flip_h = false
		idle_direction = "left"
	elif velocity.y < 0 or Input.is_action_pressed("Move Up"):
		$AnimatedSprite2D.play("up")
		idle_direction = "up"
	elif velocity.y > 0 or Input.is_action_pressed("Move Down"):
		$AnimatedSprite2D.play("down")
		idle_direction = "down"
	else:
		$AnimatedSprite2D.play("idle " + idle_direction)

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
