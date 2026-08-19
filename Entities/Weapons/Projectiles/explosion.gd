extends Area2D

var damage: int = 3

func _ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(onAnimationFinished)
	
	await get_tree().physics_frame
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Enemy"):
			body.takeDamage(damage)
	
	$AnimatedSprite2D.play("explosion")


func onAnimationFinished() -> void:
	queue_free()
