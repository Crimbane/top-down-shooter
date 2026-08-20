extends Node2D

@export var bulletScene: PackedScene
@export var altBulletScene: PackedScene
@export var bulletSpawnRight: Vector2 = Vector2(12, 0)
@export var bulletSpawnLeft: Vector2 = Vector2(-12, 0)
@export var bulletSpawnUp: Vector2 = Vector2(0, -12)
@export var bulletSpawnDown: Vector2 = Vector2(0, 12)
var bulletSpawnPosition: Vector2 = bulletSpawnRight

@export var fireRate: float = 0.5
#@export var bulletDamage: int = 1
#@export var bulletSpeed: int = 500
@export var bulletCount: int = 1
@export var bulletCountAlt: int = 1
@export var spread: float = 0.0
@export var spreadAlt: float = 0.0

@export var maxAmmo: int = 8
@export var maxAmmoAlt: int = 8
@export var magazineSize: int = 4
@export var magazineSizeAlt: int = 4
var currentAmmo: int
var currentAmmoAlt: int



var muzzleFlashOffset: Vector2 = Vector2(15, 0)

var canShoot = true

func _ready() -> void:
	$"Muzzle Flash".animation_finished.connect(onMuzzleFlashFinished)
	currentAmmo = magazineSize
	currentAmmoAlt = magazineSize
	updateAmmoUI()
	

func shoot() -> void:
	if not canShoot or currentAmmo == 0:
		return
	
	canShoot = false
	currentAmmo -= 1
	updateAmmoUI()
	
	muzzleFlash()
	
	for i in bulletCount:
		shootBullet(bulletScene)
	
	await get_tree().create_timer(fireRate).timeout
	canShoot = true

func shootAlt() -> void:
	if not canShoot or currentAmmoAlt == 0:
		return
	
	canShoot = false
	currentAmmoAlt -= 1
	updateAmmoUI()
	
	for i in bulletCountAlt:
		shootBullet(altBulletScene)
	
	await get_tree().create_timer(fireRate).timeout
	canShoot = true

func shootBullet(selectedBulletScene) -> void:
	var bullet = selectedBulletScene.instantiate()
	
	var player = get_parent().get_parent()
	var spawnOffset = player.getBulletSpawnPosition()
	
	var spawnPosition = player.global_position + spawnOffset
	
	var direction = (get_global_mouse_position() - spawnPosition).normalized()
	
	# Bullet spread
	direction = direction.rotated(randf_range(-spread, spread))
	
	bullet.global_position = spawnPosition
	bullet.direction = direction
	bullet.rotation = direction.angle()
	
	#bullet.damage = bulletDamage
	#bullet.speed = bulletSpeed
	
	if player.damageBuffActive == true:
		bullet.damage *= 2
		bullet.explosionDamage *= 2
	
	get_tree().current_scene.add_child(bullet)


func reload() -> void:
	if maxAmmo > 0:
		maxAmmo -= currentAmmo
		currentAmmo = magazineSize
	
	if maxAmmoAlt > 0:
		maxAmmoAlt -= currentAmmoAlt
		currentAmmoAlt = magazineSizeAlt
	
	updateAmmoUI()


func updateAmmoUI() -> void:
	var ammoBar = get_tree().current_scene.get_node("UI/UI Manager/HUD/Ammo Counter")
	ammoBar.max_value = magazineSize
	ammoBar.value = currentAmmo
	
	var ammoBarAlt = get_tree().current_scene.get_node("UI/UI Manager/HUD/Ammo Counter Alt")
	ammoBarAlt.max_value = magazineSizeAlt
	ammoBarAlt.value = currentAmmoAlt


func muzzleFlash() -> void:
	var player = get_parent().get_parent()
	match player.lastDirection:
		"right":
			$"Muzzle Flash".rotation = 0
			$"Muzzle Flash".position = get_parent().get_parent().getBulletSpawnPosition() + Vector2(14, 0)
		"left":
			$"Muzzle Flash".rotation = PI
			$"Muzzle Flash".position = get_parent().get_parent().getBulletSpawnPosition() + Vector2(-14, 0)
		"up":
			$"Muzzle Flash".rotation = -PI / 2
			$"Muzzle Flash".position = get_parent().get_parent().getBulletSpawnPosition() + Vector2(0, -15)
		"down":
			$"Muzzle Flash".rotation = PI / 2
			$"Muzzle Flash".position = get_parent().get_parent().getBulletSpawnPosition() + Vector2(0, 13)
	
	$"Muzzle Flash".visible = true
	$"Muzzle Flash".frame = 0
	$"Muzzle Flash".play("default")


func onMuzzleFlashFinished() -> void:
	$"Muzzle Flash".visible = false
