@tool
extends Area2D

@export var despawnTimer: int = 20

@export_enum(
	"Health", "Damage", "Shield", "Speed", "FireRate",
	"Bullet", "PiercingBullet", "BouncingBullet", "ExplosiveBullet", 
	"Buckshot", "Slug") var pickupSprite: String = "Health":
	set(value):
		pickupSprite = value
		updateSprite()




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateSprite()
	
	
	if not Engine.is_editor_hint():
		body_entered.connect(pickup)
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
	var gun = body.get_node("GunHolder").get_child(1)
	
	
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
			body.updateInventory("bullets", 20)
		"PiercingBullet":
			body.updateInventory("piercing bullets", 20)
		"Buckshot":
			body.updateInventory("buckshot", 12)
		"Slug":
			body.updateInventory("slugs", 8)
		"ExplosiveBullet":
			body.updateInventory("explosive bullets", 8)
		"BouncingBullet":
			body.updateInventory("bouncing bullets", 8)
	queue_free()
