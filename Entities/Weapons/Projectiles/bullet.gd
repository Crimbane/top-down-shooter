extends Area2D

@export var speed: int = 500
var direction = Vector2.ZERO
@export var damage: int = 5
@export var pierceCount: int = 0

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
	if body.is_in_group("Enemy"):
		body.takeDamage(damage)
	
	if explosive:
		call_deferred("explode")
		queue_free()
		return
	
	if pierceCount > 0:
		pierceCount -= 1
	else:
		queue_free()


func explode() -> void:
	if not explosive:
		return
	
	var explosion = explosionScene.instantiate()
	
	explosion.global_position = global_position
	explosion.damage = explosionDamage
	
	
	get_tree().current_scene.add_child(explosion)
