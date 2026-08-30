@tool
extends Area2D

@export var despawnTimer: int = 20

var ammoMultiplier: float = 1.0

@export_enum(
	"Health", "Damage", "Shield", "Speed", "FireRate",
	"Bullet", "PiercingBullet", "BouncingBullet", "ExplosiveBullet", 
	"Buckshot", "Slug") var pickupSprite: String = "Health":
	set(value):
		pickupSprite = value
		updateSprite()


func _ready() -> void:
	updateSprite()
	
	if not Engine.is_editor_hint():
		body_entered.connect(pickup)
		if pickupSprite == "Health" or pickupSprite == "Damage" or pickupSprite == "Shield" or pickupSprite == "Speed" or pickupSprite == "FireRate":
			await get_tree().create_timer(despawnTimer).timeout
			queue_free()


func updateSprite() -> void:
	var animatedSprite = get_node_or_null("AnimatedSprite2D")
	
	if animatedSprite == null:
		return
	
	match pickupSprite:
		"Health":
			animatedSprite.animation = "health"
		"Damage":
			animatedSprite.animation = "damage"
		"Shield":
			animatedSprite.animation = "shield"
		"Speed":
			animatedSprite.animation = "speed"
		"FireRate":
			animatedSprite.animation = "firerate"
			
		"Bullet":
			animatedSprite.animation = "bullet"
		"PiercingBullet":
			animatedSprite.animation = "piercingbullet"
		"Buckshot":
			animatedSprite.animation = "buckshot"
		"Slug":
			animatedSprite.animation = "slug"
		"ExplosiveBullet":
			animatedSprite.animation = "explosivebullet"
		"BouncingBullet":
			animatedSprite.animation = "bouncingbullet"


func pickup(body: CharacterBody2D) -> void:
	match pickupSprite:
		"Health":
			body.heal(5)
		"Damage":
			body.damageBuff()
		"Shield":
			body.shieldBuff()
		"Speed":
			body.speedBuff()
		"FireRate":
			body.fireRateBuff()
		
		"Bullet":
			body.updateInventory("bullets", 10 * ammoMultiplier) #ammo is added to current and max
			GameManager.playPickupSound()
		"PiercingBullet":
			body.updateInventory("piercing bullets", 10 * ammoMultiplier)
			GameManager.playPickupSound()
		"Buckshot":
			body.updateInventory("buckshot", 6 * ammoMultiplier)
			GameManager.playPickupSound()
		"Slug":
			body.updateInventory("slugs", 4 * ammoMultiplier)
			GameManager.playPickupSound()
		"ExplosiveBullet":
			body.updateInventory("explosive bullets", 4 * ammoMultiplier)
			GameManager.playPickupSound()
		"BouncingBullet":
			body.updateInventory("bouncing bullets", 4 * ammoMultiplier)
			GameManager.playPickupSound()
	queue_free()
