extends Node2D


var radius: float = 0

func _process(_delta: float) -> void:
	queue_redraw()

func playEffect() -> void:
	var tween = create_tween()
	tween.tween_property(self, "radius", 1500, 1).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var center: Vector2 = Vector2.ZERO
	var start_angle: float = 0 
	var end_angle: float = TAU
	var point_count: int = 50
	var color: Color = Color.WHITE
	color.a = 0.25
	var width: float = 10
	var antialiased: bool = true
	
	draw_arc(center, radius, start_angle, end_angle, point_count, color, width, antialiased)
