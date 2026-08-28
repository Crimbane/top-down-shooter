extends CharacterBody2D

signal hit
signal healthChanged(currentHealth)

var lastDirection: String = "down"

var maxHealth: int = 5
@onready var currentHealth: int = maxHealth
const NORMAL_SPEED = 300.0
var speed = NORMAL_SPEED
var iFrameTimer: float = 0.5

var damageBuffActive = false
var fireRateBuffActive = false
var shieldBuffActive = false

var damageTakenRecently = false
var shootLocked: bool = false

var currentGun: Node2D
var rifleScene = preload("uid://4wwqaebiasr3")
var shotgunScene = preload("uid://dp1kk0cs51e68")
var C4_TTScene = preload("uid://cjt02kx5neh4v")

var currentWeaponIndex: int = 0

var weaponScenes: Array[PackedScene] = [
	rifleScene,
	shotgunScene,
	C4_TTScene
]

var ammoInventoryCurrent = {
	"bullets": 10,
	"piercing bullets": 0,
	"buckshot": 0,
	"slugs": 0,
	"explosive bullets": 0,
	"bouncing bullets": 0
}

var ammoInventoryMax = {
	"bullets": 999,
	"piercing bullets": 0,
	"buckshot": 0,
	"slugs": 0,
	"explosive bullets": 0,
	"bouncing bullets": 0
}





func _ready() -> void:
	hit.connect(onHit)
	$"Timers/Damage Buff Timer".timeout.connect(onDamageBuffTimerTimeout)
	$"Timers/Speed Buff Timer".timeout.connect(onSpeedBuffTimerTimeout)
	$"Timers/Shield Buff Timer".timeout.connect(onShieldBuffTimerTimeout)
	switchWeapon(0)
	repathLoop()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Weapon 1"):
		switchWeapon(0)
		currentGun.maxAmmo = ammoInventoryMax["bullets"]
		currentGun.maxAmmoAlt = ammoInventoryMax["piercing bullets"]
		currentGun.updateAmmoUI()
	
	if Input.is_action_just_pressed("Weapon 2"):
		switchWeapon(1)
		currentGun.maxAmmo = ammoInventoryMax["buckshot"]
		currentGun.maxAmmoAlt = ammoInventoryMax["slugs"]
		currentGun.updateAmmoUI()
	
	if Input.is_action_just_pressed("Weapon 3"):
		switchWeapon(2)
		currentGun.maxAmmo = ammoInventoryMax["explosive bullets"]
		currentGun.maxAmmoAlt = ammoInventoryMax["bouncing bullets"]
		currentGun.updateAmmoUI()
	
	if Input.is_action_pressed("Shoot"):
		if currentGun and not shootLocked:
			currentGun.shoot()
	
	if Input.is_action_just_released("Shoot"):
		shootLocked = false
	
	if Input.is_action_just_pressed("Change bullet"):
		if currentGun:
			currentGun.changeBullet()
	
	if Input.is_action_pressed("Reload"):
		if currentGun:
			currentGun.reload()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()
	
	animations()


func updateInventory(itemName, amount: int) -> void:
	ammoInventoryMax[itemName] += amount
	currentGun.updateAmmoUI()
	


func repathLoop() -> void:
	while true:
		await get_tree().create_timer(3).timeout
		print(ammoInventoryMax)


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
	if damageTakenRecently == true:
		return
	
	print("Player took ", damage, " damage")
	if damage > 0:
		currentHealth -= damage
	
	healthChanged.emit(currentHealth)
	
	if currentHealth <= 0:
		die()
	print("Player health: ", currentHealth)
	
	iFramesWhenHit()


func heal(healing: int) -> void:
	print("Player healed ", healing, " health")
	currentHealth += healing
	
	if currentHealth >= maxHealth:
		currentHealth = maxHealth
	
	healthChanged.emit(currentHealth)


func damageBuff() -> void:
	damageBuffActive = true
	$"Timers/Damage Buff Timer".start()


func onDamageBuffTimerTimeout() -> void:
	damageBuffActive = false


func fireRateBuff() -> void:
	fireRateBuffActive = true
	$"Timers/Fire Rate Buff Timer".start()


func fireRateBuffTimerTimeout() -> void:
	fireRateBuffActive = false

func speedBuff() -> void:
	speed = NORMAL_SPEED * 1.5
	$"Timers/Speed Buff Timer".start()


func onSpeedBuffTimerTimeout() -> void:
	speed = NORMAL_SPEED


func iFramesWhenHit() -> void:
	damageTakenRecently = true
	
	# damage animation
	match lastDirection:
		"right":
			pass
		"left":
			pass
		"up":
			pass
		"down":
			pass
	
	await get_tree().create_timer(iFrameTimer).timeout
	damageTakenRecently = false
	


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


func switchWeapon(index: int) -> void:
	if currentGun:
		currentGun.queue_free()
	
	currentGun = weaponScenes[index].instantiate()
	$GunHolder.add_child(currentGun)
	
	$"GunHolder/Bullet Spawn".position = currentGun.bulletSpawnPosition
	
	currentGun.updateAmmoUI()
	
	currentWeaponIndex = index
