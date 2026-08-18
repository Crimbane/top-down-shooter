extends CharacterBody2D

signal hit

var maxHealth: int = 5
@onready var currentHealth: int = maxHealth
const NORMAL_SPEED = 300.0
var speed = NORMAL_SPEED

var damageBuffActive = false
var shieldBuffActive = false

var currentGun: Node2D
var pistolScene = preload("uid://4wwqaebiasr3")
var shotgunScene = preload("uid://dp1kk0cs51e68")

var lastDirection: String = "down"

func _ready() -> void:
	hit.connect(onHit)
	$"Timers/Damage Buff Timer".timeout.connect(onDamageBuffTimerTimeout)
	$"Timers/Speed Buff Timer".timeout.connect(onSpeedBuffTimerTimeout)
	$"Timers/Shield Buff Timer".timeout.connect(onShieldBuffTimerTimeout)
	equipGun(shotgunScene)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("Shoot"):
		if currentGun:
			currentGun.shoot()


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
	if currentGun == null:
		if velocity.x > 0 or Input.is_action_pressed("Move Right"):
			$AnimatedSprite2D.play("right")
			#$AnimatedSprite2D.flip_h = true
			lastDirection = "right"
		
		elif velocity.x < 0 or Input.is_action_pressed("Move Left"):
			$AnimatedSprite2D.play("left")
			#$AnimatedSprite2D.flip_h = false
			lastDirection = "left"
		
		elif velocity.y < 0 or Input.is_action_pressed("Move Up"):
			$AnimatedSprite2D.play("up")
			lastDirection = "up"
		
		elif velocity.y > 0 or Input.is_action_pressed("Move Down"):
			$AnimatedSprite2D.play("down")
			lastDirection = "down"
			
		else:
			$AnimatedSprite2D.play("idle " + lastDirection)
	
	if currentGun != null:
		updateFacingDirection()
		
		if velocity != Vector2.ZERO:
			match lastDirection:
				"right":
					$AnimatedSprite2D.play("gun right")
				
				"left":
					$AnimatedSprite2D.play("gun left")
				
				"up":
					$AnimatedSprite2D.play("gun up")
				
				"down":
					$AnimatedSprite2D.play("gun down")
		else:
			$AnimatedSprite2D.play("gun idle " + lastDirection)


func takeDamage(damage: int) -> void:
	if shieldBuffActive:
		print("Shield blocked damage")
		return
	
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
	shieldBuffActive = true
	$"Timers/Shield Buff Timer".start()
	$"Shield Sprite".visible = true

func onShieldBuffTimerTimeout() -> void:
	shieldBuffActive = false
	$"Shield Sprite".visible = false

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


func updateFacingDirection() -> void:
	var mousePosition = get_global_mouse_position()
	var direction = mousePosition - global_position

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			lastDirection = "right"
		else:
			lastDirection = "left"
	else:
		if direction.y > 0:
			lastDirection = "down"
		else:
			lastDirection = "up"
