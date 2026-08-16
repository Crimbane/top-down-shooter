extends Node2D

@export var bulletScene: PackedScene
@export var fireRate: float = 0.5
@export var bulletDamage: int = 1
@export var bulletSpeed: int = 500
@export var bulletCount: int = 1
@export var spread: float = 0.0

var canShoot = true

@onready var bulletSpawn = $BulletSpawn

func _ready() -> void:
	pass 

func shoot() -> void:
	if not canShoot:
		return
	
	canShoot = false
	
	for i in bulletCount:
		shootBullet()
	print("Shoot")
	await get_tree().create_timer(fireRate).timeout
	canShoot = true

func shootBullet() -> void:
	var bullet = bulletScene.instantiate()
	
	var direction = (get_global_mouse_position() - bulletSpawn.global_position).normalized()
	
	# Bullet spread
	direction = direction.rotated(randf_range(-spread, spread))
	
	bullet.global_position = bulletSpawn.global_position
	bullet.direction = direction
	bullet.rotation = direction.angle()
	
	bullet.damage = bulletDamage
	bullet.speed = bulletSpeed
	
	var player = get_parent().get_parent()
	if player.damageBuffActive == true:
		bullet.damage *= 2
	
	get_tree().current_scene.add_child(bullet)
