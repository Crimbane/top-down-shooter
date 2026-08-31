extends AnimatedSprite2D



func _ready() -> void:
	offset = Vector2(-12, 0)
	play("impact")
	$"Impact Sound".play()
	
	await $"Impact Sound".finished
	queue_free()
