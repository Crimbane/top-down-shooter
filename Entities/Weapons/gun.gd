extends Node2D

@export_category("Gun")
@export var gunName: String
@export var bulletScene: PackedScene
@export var altBulletScene: PackedScene
@export_group("Bullet Spawn")
@export var bulletSpawnRight: Vector2 = Vector2(12, 0)
@export var bulletSpawnLeft: Vector2 = Vector2(-12, 0)
@export var bulletSpawnUp: Vector2 = Vector2(0, -12)
@export var bulletSpawnDown: Vector2 = Vector2(0, 12)
var bulletSpawnPosition: Vector2 = bulletSpawnRight

@export_category("Stats")
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

var usingAltBullet: bool = false
const CHANGEBULLETTIME: float = 0.5
var isSwitchingBullet: bool = false
var isReloading: bool = false
@export var reloadTime: float = 2.0

var muzzleFlashOffset: Vector2 = Vector2(15, 0)

var canShoot: bool = true

func _ready() -> void:
	$"Muzzle Flash".animation_finished.connect(onMuzzleFlashFinished)
	currentAmmo = magazineSize
	currentAmmoAlt = magazineSizeAlt
	updateAmmoUI()
	
	var ui = get_tree().current_scene.get_node("UI/UI Manager")
	ui.updateActiveBullet(usingAltBullet)
	

func shoot() -> void:
	if isReloading or isSwitchingBullet:
		return
	
	if not canShoot:
		return
	
	canShoot = false
	
	if usingAltBullet:
		if currentAmmoAlt == 0:
			canShoot = true
			return
		
		currentAmmoAlt -= 1
		
		for i in bulletCountAlt:
			shootBullet(altBulletScene, spreadAlt)
	
	else:
		if currentAmmo == 0:
			canShoot = true
			return
		
		currentAmmo -= 1
		
		for i in bulletCount:
			shootBullet(bulletScene, spread)
	
	updateAmmoUI()
	muzzleFlash()
	
	await get_tree().create_timer(fireRate).timeout
	if not isReloading and not isSwitchingBullet:
		canShoot = true

#func shootAlt() -> void:
	#if not canShoot or currentAmmoAlt == 0:
		#return
	#
	#canShoot = false
	#currentAmmoAlt -= 1
	#updateAmmoUI()
	#
	#for i in bulletCountAlt:
		#shootBullet(altBulletScene, spreadAlt)
	#
	#await get_tree().create_timer(fireRate).timeout
	#canShoot = true

func shootBullet(selectedBulletScene: PackedScene, bulletSpread: float) -> void:
	var bullet = selectedBulletScene.instantiate()
	
	var player = get_parent().get_parent()
	var spawnOffset = player.getBulletSpawnPosition()
	
	var spawnPosition = player.global_position + spawnOffset
	
	var direction = (get_global_mouse_position() - spawnPosition).normalized()
	
	# Bullet spread
	direction = direction.rotated(randf_range(-bulletSpread, bulletSpread))
	
	bullet.global_position = spawnPosition
	bullet.direction = direction
	bullet.rotation = direction.angle()
	
	#bullet.damage = bulletDamage
	#bullet.speed = bulletSpeed
	
	if player.damageBuffActive == true:
		bullet.damage *= 2
		bullet.explosionDamage *= 2
	
	get_tree().current_scene.add_child(bullet)


func changeBullet() -> void:
	if isReloading or isSwitchingBullet:
		return
	
	canShoot = false
	isSwitchingBullet = true
	
	
	var ui = get_tree().current_scene.get_node("UI/UI Manager")
	await ui.startActionProgress(CHANGEBULLETTIME)
	
	if usingAltBullet == true:
		usingAltBullet = false
	else:
		usingAltBullet = true
	
	ui.updateActiveBullet(usingAltBullet)
	updateAmmoUI()
	
	isSwitchingBullet = false
	if not isReloading and not isSwitchingBullet:
		canShoot = true
	
	var player = get_parent().get_parent()
	player.shootLocked = Input.is_action_pressed("Shoot")


func reload() -> void:
	if isReloading or isSwitchingBullet:
		return
	
	if currentAmmo == magazineSize and currentAmmoAlt == magazineSizeAlt:
		return
	
	isReloading = true
	canShoot = false
	
	var ui = get_tree().current_scene.get_node("UI/UI Manager")
	await ui.startActionProgress(reloadTime)
	
	if maxAmmo > 0:
		maxAmmo = maxAmmo - magazineSize + currentAmmo
		currentAmmo = magazineSize
	
	if maxAmmoAlt > 0:
		maxAmmoAlt = maxAmmoAlt - magazineSizeAlt + currentAmmoAlt
		currentAmmoAlt = magazineSizeAlt
	
	updateAmmoUI()
	
	isReloading = false
	canShoot = true
	
	var player = get_parent().get_parent()
	player.shootLocked = Input.is_action_pressed("Shoot")


func updateAmmoUI() -> void:
	var ammoCounterLabel = get_tree().current_scene.get_node("UI/UI Manager/HUD/Bottom Left/VBox/HBox Bullet/Ammo Counter Bottom")
	ammoCounterLabel.text = str(currentAmmo) + " / " + str(magazineSize)
	
	var ammoCounterLabelAlt = get_tree().current_scene.get_node("UI/UI Manager/HUD/Bottom Left/VBox/HBox Bullet Alt/Ammo Counter Bottom Alt")
	ammoCounterLabelAlt.text = str(currentAmmoAlt) + " / " + str(magazineSizeAlt)
	
	var weaponNameLabel = get_tree().current_scene.get_node("UI/UI Manager/HUD/Bottom Left/VBox/Weapon Name")
	weaponNameLabel.text = str(gunName)
	
	var maxAmmoLabel = get_tree().current_scene.get_node("UI/UI Manager/HUD/Bottom Left/VBox/Max Ammo")
	maxAmmoLabel.text = "Reserve Ammo: " + str(maxAmmo) + " / " + str(maxAmmoAlt)
	
	var weaponIcon = get_tree().current_scene.get_node("UI/UI Manager/HUD/Bottom Left/VBox/Weapon Icon")
	var bulletIcon = get_tree().current_scene.get_node("UI/UI Manager/HUD/Bottom Left/VBox/HBox Bullet/Bullet Icon")
	var bulletIconAlt = get_tree().current_scene.get_node("UI/UI Manager/HUD/Bottom Left/VBox/HBox Bullet Alt/Bullet Icon Alt")
	
	match gunName:
		"Rifle":
			weaponIcon.texture = load("uid://dgi4ojqg7g3e2")
			bulletIcon.texture = load("uid://dgi4ojqg7g3e2")
			bulletIconAlt.texture = load("uid://bu0finc31bw61")
		"Shotgun":
			weaponIcon.texture = load("uid://xehr7o8em82r")
			bulletIcon.texture = load("uid://xehr7o8em82r")
			bulletIconAlt.texture = load("uid://blwdun6u52mrb")
		"C4-TT":
			weaponIcon.texture = load("uid://bdwoh4vr4v8qv")
			bulletIcon.texture = load("uid://bdwoh4vr4v8qv")
			bulletIconAlt.texture = load("uid://dahb6wgmn2pps")


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
