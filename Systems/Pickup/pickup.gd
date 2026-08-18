@tool
extends Area2D

@export var despawnTimer: int = 20

@export_enum("Health", "Damage", "Shield", "Speed") var pickupSprite: String = "Health":
	set(value):
		pickupSprite = value
		updateSprite()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(pickup)
	updateSprite()
	
	if not Engine.is_editor_hint():
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
	queue_free()
