extends CharacterBody2D

@export var health: int = 10

var SPEED = 30
var reachedTarget = false

@onready var target = get_tree().current_scene.get_node("Player")

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING #Ignore floor and ceiling
	#print("Distance to player: ", global_position.distance_to(target.position))
	
	$Area2D.body_entered.connect(stopPathfinding)

func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	if target:
		var direction = (target.global_position - global_position).normalized()
		if reachedTarget == false:
			velocity = direction * SPEED
	
	move_and_slide()


func stopPathfinding(body: Node2D) -> void:
	if body.name == "Player":
		print("Bird Reached target")
		reachedTarget = true
		velocity = Vector2.ZERO
		body.takeDamage(1)


func takeDamage(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		die()

func die() -> void:
	queue_free()
