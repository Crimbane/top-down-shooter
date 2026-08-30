extends CharacterBody2D

signal hit
signal healthChanged(currentHealth)

var lastDirection: String = "down"

var maxHealth: int = 5
@onready var currentHealth: int = maxHealth
const NORMAL_SPEED = 150
var speed = NORMAL_SPEED
var iFrameTimer: float = 0.5

var damageBuffActive: bool = false
var fireRateBuffActive: bool = false
var shieldBuffActive: bool = false

var damageTakenRecently: bool = false
var playingDamageAnimation: bool = false
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
	"piercing bullets": 5,
	"buckshot": 3,
	"slugs": 2,
	"explosive bullets": 2,
	"bouncing bullets": 2
}

var ammoInventoryMax = {
	"bullets": 999,
	"piercing bullets": 99,
	"buckshot": 99,
	"slugs": 99,
	"explosive bullets": 99,
	"bouncing bullets": 99
}

func _ready() -> void:
	hit.connect(onHit)
	$"Timers/Damage Buff Timer".timeout.connect(onDamageBuffTimerTimeout)
	$"Timers/Speed Buff Timer".timeout.connect(onSpeedBuffTimerTimeout)
	$"Timers/Shield Buff Timer".timeout.connect(onShieldBuffTimerTimeout)
	switchWeapon(0)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Weapon 1"):
		switchWeapon(0)
		
	
	if Input.is_action_just_pressed("Weapon 2"):
		switchWeapon(1)
	
	if Input.is_action_just_pressed("Weapon 3"):
		switchWeapon(2)
	
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
	
	match itemName:
		"bullets":
			if currentWeaponIndex == 0:
				currentGun.maxAmmo = ammoInventoryMax[itemName]
		
		"piercing bullets":
			if currentWeaponIndex == 0:
				currentGun.maxAmmoAlt = ammoInventoryMax[itemName]
		
		"buckshot":
			if currentWeaponIndex == 1:
				currentGun.maxAmmo = ammoInventoryMax[itemName]
		
		"slugs":
			if currentWeaponIndex == 1:
				currentGun.maxAmmoAlt = ammoInventoryMax[itemName]
		
		"explosive bullets":
			if currentWeaponIndex == 2:
				currentGun.maxAmmo = ammoInventoryMax[itemName]
		
		"bouncing bullets":
			if currentWeaponIndex == 2:
				currentGun.maxAmmoAlt = ammoInventoryMax[itemName]
	
	currentGun.updateAmmoUI()


func onHit() -> void:
	pass


func restartGame() -> void:
	get_tree().reload_current_scene()


func animations() -> void:
	if playingDamageAnimation:
		return
	
	$AnimatedSprite2D.flip_h = false
	
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
	playingDamageAnimation= true
	
	match lastDirection:
		"right":
			$AnimatedSprite2D.play("damaged right")
			$AnimatedSprite2D.flip_h = true
		"left":
			$AnimatedSprite2D.play("damaged left")
			$AnimatedSprite2D.flip_h = false
		"up":
			$AnimatedSprite2D.play("damaged up")
		"down":
			$AnimatedSprite2D.play("damaged down")
	
	await get_tree().create_timer(iFrameTimer).timeout
	
	damageTakenRecently = false
	playingDamageAnimation= false
	


func shieldBuff() -> void:
	shieldBuffActive = true
	$"Timers/Shield Buff Timer".start()
	$"Shield Sprite".visible = true


func onShieldBuffTimerTimeout() -> void:
	shieldBuffActive = false
	$"Shield Sprite".visible = false


func die() -> void:
	#load death screen
	GameManager.endRun()
	
	call_deferred("restartGame")


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
	if currentGun and currentWeaponIndex == index:
		return
	
	if currentGun:
		match currentWeaponIndex:
			0:
				ammoInventoryCurrent["bullets"] = currentGun.currentAmmo
				ammoInventoryCurrent["piercing bullets"] = currentGun.currentAmmoAlt
				
				ammoInventoryMax["bullets"] = currentGun.maxAmmo
				ammoInventoryMax["piercing bullets"] = currentGun.maxAmmoAlt
			
			1:
				ammoInventoryCurrent["buckshot"] = currentGun.currentAmmo
				ammoInventoryCurrent["slugs"] = currentGun.currentAmmoAlt
				
				ammoInventoryMax["buckshot"] = currentGun.maxAmmo
				ammoInventoryMax["slugs"] = currentGun.maxAmmoAlt
			
			2:
				ammoInventoryCurrent["explosive bullets"] = currentGun.currentAmmo
				ammoInventoryCurrent["bouncing bullets"] = currentGun.currentAmmoAlt
				
				ammoInventoryMax["explosive bullets"] = currentGun.maxAmmo
				ammoInventoryMax["bouncing bullets"] = currentGun.maxAmmoAlt
				
		currentGun.queue_free()
	
	currentGun = weaponScenes[index].instantiate()
	$GunHolder.add_child(currentGun)
	
	$"GunHolder/Bullet Spawn".position = currentGun.bulletSpawnPosition
	
	match index:
		0:
			currentGun.currentAmmo = ammoInventoryCurrent["bullets"]
			currentGun.currentAmmoAlt = ammoInventoryCurrent["piercing bullets"]
			
			currentGun.maxAmmo = ammoInventoryMax["bullets"]
			currentGun.maxAmmoAlt = ammoInventoryMax["piercing bullets"]
		
		1:
			currentGun.currentAmmo = ammoInventoryCurrent["buckshot"]
			currentGun.currentAmmoAlt = ammoInventoryCurrent["slugs"]
			
			currentGun.maxAmmo = ammoInventoryMax["buckshot"]
			currentGun.maxAmmoAlt = ammoInventoryMax["slugs"]
		
		2:
			currentGun.currentAmmo = ammoInventoryCurrent["explosive bullets"]
			currentGun.currentAmmoAlt = ammoInventoryCurrent["bouncing bullets"]
			
			currentGun.maxAmmo = ammoInventoryMax["explosive bullets"]
			currentGun.maxAmmoAlt = ammoInventoryMax["bouncing bullets"]
	
	currentGun.updateAmmoUI()
	currentWeaponIndex = index
