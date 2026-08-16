extends CharacterBody2D

@export var health: int = 1

var SPEED = 100
var reachedTarget = false
var findTarget = false

@onready var target = get_parent().get_node("Player")

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING #Ignore floor and ceiling
	print("Distance to player: ", global_position.distance_to(target.position))
	
	$Area2D.body_entered.connect(stopPathfinding)
	$Area2D.body_exited.connect(resumePathfinding)

func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	startPathfinding()
	
	if findTarget == true:
		var direction = (target.global_position - global_position).normalized()
		if reachedTarget == false:
			velocity = direction * SPEED
	
	move_and_slide()


func stopPathfinding(body: Node2D) -> void:
	if body == target:
		print("Short reached target")
		reachedTarget = true
		velocity = Vector2.ZERO
		body.hit.emit() 
		body.takeDamage(3)

func startPathfinding() -> void:
	if global_position.distance_to(target.position) < 150:
		findTarget = true
	else:
		findTarget = false
		velocity = Vector2.ZERO


func resumePathfinding(body: Node2D) -> void:
	if body == target:
		print("Target left range!")
		reachedTarget = false

func takeDamage(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		die()

func die() -> void:
	queue_free()
