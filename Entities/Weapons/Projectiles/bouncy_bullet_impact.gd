extends AnimatedSprite2D



func _ready() -> void:
	offset = Vector2(-12, 0)
	play("impact")
	await animation_finished
	queue_free()
