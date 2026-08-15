extends CharacterBody2D

var SPEED = 1
var reachedTarget = false
var findTarget = false

@onready var target = get_parent().get_node("Player")

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING #Ignore floor and ceiling
	print("Distance to player: ", global_position.distance_to(target.position))
	
	$Area2D.body_entered.connect(stopPathfinding)

func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	startPathfinding()
	
	if findTarget == true:
		var direction = (target.global_position - global_position)
		if reachedTarget == false:
			velocity = direction * SPEED
	
	move_and_slide()


func stopPathfinding(body: Node2D) -> void:
	if body.name == "Player":
		print("Reached target")
		reachedTarget = true
		velocity = Vector2.ZERO

func startPathfinding() -> void:
	if global_position.distance_to(target.position) < 150:
		findTarget = true
	else:
		findTarget = false
		velocity = Vector2.ZERO
