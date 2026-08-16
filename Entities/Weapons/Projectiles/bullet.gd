extends Area2D

var speed = 500
var direction = Vector2.ZERO
var damage: int = 5
var pierceCount: int = 0

func _ready() -> void:
	body_entered.connect(bulletHit)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func bulletHit(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.takeDamage(damage)
	
	if pierceCount > 0:
		pierceCount -= 1
	else:
		queue_free()
