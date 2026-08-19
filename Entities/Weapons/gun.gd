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

var muzzleFlashOffset: Vector2 = Vector2(15, 0)

var canShoot = true

func _ready() -> void:
	$"Muzzle Flash".animation_finished.connect(onMuzzleFlashFinished)
	

func shoot() -> void:
	if not canShoot:
		return
	
	canShoot = false
	
	muzzleFlash()
	
	for i in bulletCount:
		shootBullet(bulletScene)
	
	await get_tree().create_timer(fireRate).timeout
	canShoot = true

func shootAlt() -> void:
	if not canShoot:
		return
	
	canShoot = false
	
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


func setBuckshot() -> void:
	bulletScene = preload("uid://c7upwuv7l3c1p")
	bulletCount = 8
	spread = 0.15


func setSlug() -> void:
	bulletScene = preload("uid://cmumnfsyy3ysh")
	bulletCount = 1
	spread = 0.0


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
