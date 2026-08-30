extends Area2D

var pickupScene = preload("uid://b1v2i1jgbgqj2")

@export_enum(
	"Buffs", "Ammo") var spawnType: String = "Ammo":
	set(value):
		spawnType = value


func _ready() -> void:
	if spawnType == "Buffs":
		$"Buff Spawn Timer".timeout.connect(onSpawnBuffTimerTimeout)
	elif spawnType == "Ammo":
		$"Ammo Spawn Timer".timeout.connect(onSpawnAmmoTimerTimeout)



func createBuffPickup() -> void:
	var pickup = pickupScene.instantiate()
	
	var pickupTypes = ["Health", "Damage", "Shield", "Speed"]
	pickup.pickupSprite = pickupTypes.pick_random()
	
	pickup.global_position = global_position
	
	get_parent().call_deferred("add_child", pickup)


func createAmmoPickup() -> void:
	var pickup = pickupScene.instantiate()
	
	var pickupTypes = ["Bullet", "PiercingBullet", "BouncingBullet", "ExplosiveBullet", 
	"Buckshot", "Slug"]
	pickup.pickupSprite = pickupTypes.pick_random()
	
	pickup.global_position = global_position
	
	get_parent().call_deferred("add_child", pickup)



func onSpawnBuffTimerTimeout() -> void:
	createBuffPickup()


func onSpawnAmmoTimerTimeout() -> void:
	createAmmoPickup()
