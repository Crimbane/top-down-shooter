extends CharacterBody2D

signal hit

var maxHealth: int = 5
@onready var currentHealth: int = maxHealth
const NORMAL_SPEED = 300.0
var speed = NORMAL_SPEED

var damageBuffActive = false
var damageBuffTimer = 10
var speedBuffTimer = 10

var currentGun: Node2D

var pistolScene = preload("uid://4wwqaebiasr3")
var shotgunScene = preload("uid://dp1kk0cs51e68")

var lastDirection: String = "down"

func _ready() -> void:
	hit.connect(onHit)
	$"Timers/Damage Buff Timer".timeout.connect(onDamageBuffTimerTimeout)
	$"Timers/Speed Buff Timer".timeout.connect(onSpeedBuffTimerTimeout)
	equipGun(shotgunScene)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("Shoot"):
		if currentGun:
			currentGun.shoot()

	if velocity.x > 0 or Input.is_action_pressed("Move Right"):
		$AnimatedSprite2D.play("right")
		#$AnimatedSprite2D.flip_h = true
		idle_direction = "right"
	elif velocity.x < 0 or Input.is_action_pressed("Move Left"):
		$AnimatedSprite2D.play("left")
		#$AnimatedSprite2D.flip_h = false
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
	var direction := Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()
	
	animations()


func onHit() -> void:
	pass


func restartGame() -> void:
	get_tree().reload_current_scene()


func animations() -> void:
	if velocity.x > 0 or Input.is_action_pressed("Move Right"):
		$AnimatedSprite2D.play("right")
		$AnimatedSprite2D.flip_h = true
		lastDirection = "right"
		
	elif velocity.x < 0 or Input.is_action_pressed("Move Left"):
		$AnimatedSprite2D.play("left")
		$AnimatedSprite2D.flip_h = false
		lastDirection = "left"
		
	elif velocity.y < 0 or Input.is_action_pressed("Move Up"):
		$AnimatedSprite2D.play("up")
		lastDirection = "up"
		
	elif velocity.y > 0 or Input.is_action_pressed("Move Down"):
		$AnimatedSprite2D.play("down")
		lastDirection = "down"
		
	else:
		$AnimatedSprite2D.play("idle " + lastDirection)


func takeDamage(damage: int) -> void:
	print("Player took ", damage, " damage")
	if damage > 0:
		currentHealth -= damage
	
	if currentHealth <= 0:
		die()
	print("Player health: ", currentHealth)


func heal(healing: int) -> void:
	print("Player healed ", healing, " health")
	currentHealth += healing
	
	if currentHealth >= maxHealth:
		currentHealth = maxHealth


func damageBuff() -> void:
	damageBuffActive = true
	$"Timers/Damage Buff Timer".start()

func onDamageBuffTimerTimeout() -> void:
	damageBuffActive = false


func speedBuff() -> void:
	speed = NORMAL_SPEED * 1.5
	$"Timers/Speed Buff Timer".start()

func onSpeedBuffTimerTimeout() -> void:
	speed = NORMAL_SPEED


func shieldBuff() -> void:
	pass


func die() -> void:
	#load death screen
	call_deferred("restartGame")


func equipGun(gunScene: PackedScene) -> void:
	if currentGun:
		currentGun.queue_free()

	currentGun = gunScene.instantiate()
	$GunHolder.add_child(currentGun)
	
	$"GunHolder/Bullet Spawn".position = currentGun.bulletSpawnPosition


func getBulletSpawnPosition() -> Vector2:
	match lastDirection:
		"right":
			return currentGun.bulletSpawnRight
		"left":
			return currentGun.bulletSpawnLeft
		"up":
			return currentGun.bulletSpawnUp
		"down":
			return currentGun.bulletSpawnDown
	
	return Vector2.ZERO
