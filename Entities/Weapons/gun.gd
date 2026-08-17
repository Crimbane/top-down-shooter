extends Node2D

@export var bulletScene: PackedScene
@export var bulletSpawnRight: Vector2 = Vector2(12, 0)
@export var bulletSpawnLeft: Vector2 = Vector2(-12, 0)
@export var bulletSpawnUp: Vector2 = Vector2(0, -12)
@export var bulletSpawnDown: Vector2 = Vector2(0, 12)
var bulletSpawnPosition: Vector2 = bulletSpawnRight

@export var fireRate: float = 0.5
@export var bulletDamage: int = 1
@export var bulletSpeed: int = 500
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
		shootBullet()
	
	await get_tree().create_timer(fireRate).timeout
	canShoot = true

func shootBullet() -> void:
	var bullet = bulletScene.instantiate()
	
	var player = get_parent().get_parent()
	var spawnOffset = player.getBulletSpawnPosition()
	
	var spawnPosition = player.global_position + spawnOffset
	
	var direction = (get_global_mouse_position() - spawnPosition).normalized()
	
	# Bullet spread
	direction = direction.rotated(randf_range(-spread, spread))
	
	bullet.global_position = spawnPosition
	bullet.direction = direction
	bullet.rotation = direction.angle()
	
	bullet.damage = bulletDamage
	bullet.speed = bulletSpeed
	
	if player.damageBuffActive == true:
		bullet.damage *= 2
	
	get_tree().current_scene.add_child(bullet)
