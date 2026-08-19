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
@export var spread: float = 0.0

var canShoot = true

func _ready() -> void:
	pass

func shoot() -> void:
	if not canShoot:
		return
	
	canShoot = false
	
	for i in bulletCount:
		shootBullet(bulletScene)
	
	await get_tree().create_timer(fireRate).timeout
	canShoot = true

func shootAlt() -> void:
	if not canShoot:
		return
	
	canShoot = false
	
	for i in bulletCount:
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
