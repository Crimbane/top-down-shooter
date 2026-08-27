extends CharacterBody2D


@export var speed: int = 500
var direction: Vector2 = Vector2.ZERO
@export var damage: int = 5
@export var bounceCount: int = 3
@export var impactScene: PackedScene

func _ready() -> void:
	await get_tree().create_timer(10).timeout
	queue_free()

func _physics_process(delta):
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		
		if body.is_in_group("Enemy"):
			body.takeDamage(damage)
			queue_free()
		
		if bounceCount > 0:
			bounceCount -= 1
			direction = direction.bounce(collision.get_normal()).normalized()
			rotation = direction.angle()
			createImpact()
		else:
			queue_free()

func createImpact() -> void:
	var impact = impactScene.instantiate()
	
	impact.global_position = global_position
	#impact.direction = direction
	impact.rotation = direction.angle()
	
	get_tree().current_scene.add_child(impact)
