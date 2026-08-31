extends Area2D

@export var speed: int = 500
var direction = Vector2.ZERO
@export var damage: int = 5
@export var pierceCount: int = 0

var hasHit: bool = false

@export var explosionScene: PackedScene
@export var explosive: bool = false
@export var explosionDamage: int = 3

func _ready() -> void:
	body_entered.connect(bulletHit)
	await get_tree().create_timer(10).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func bulletHit(body: Node2D) -> void:
	if hasHit:
		return
	
	GameManager.playImpactSound()
	
	if body.is_in_group("Enemy"):
		body.takeDamage(damage)
	
	if explosive:
		call_deferred("explode")
		queue_free()
		return
	
	if pierceCount > 0:
		$AnimatedSprite2D.play("impact")
		if body.is_in_group("World"):
			pierceCount -= 100
		else:
			pierceCount -= 1
	else:
		hasHit = true
		speed = 0
		set_deferred("monitoring", false)
		
		$AnimatedSprite2D.offset = Vector2(-12, 0)
		$AnimatedSprite2D.play("impact")
		await $AnimatedSprite2D.animation_finished
		queue_free()


func explode() -> void:
	if not explosive:
		return
	
	var explosion = explosionScene.instantiate()
	
	explosion.global_position = global_position
	explosion.damage = explosionDamage
	
	
	get_tree().current_scene.add_child(explosion)
