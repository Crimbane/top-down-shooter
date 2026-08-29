@tool
extends Node2D


@onready var spawnArea = $SpawnArea
@onready var spawnTimer = $Timer
@onready var enemyContainer = $EnemyContainer

@export var spawnShape: Shape2D = RectangleShape2D.new():
	set(new_shape):
		if new_shape is RectangleShape2D or new_shape is CircleShape2D:
			spawnShape = new_shape
			if spawnArea:
				spawnArea.shape = spawnShape
		else:
			push_error("Only Rectangle and Circle shapes are allowed.")
@export var enemy: Array[PackedScene]
@export var spawnTime: int = 10:
	set(new_value):
		spawnTime = new_value
		if spawnTimer:
			spawnTimer.wait_time = spawnTime
@export var enemyLimit: int = 3

var player
var tilemap: TileMapLayer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if get_tree().current_scene:
		tilemap  = get_tree().current_scene.get_node_or_null("Dungeon Tileset/BackgroundLayer")
		
	if spawnArea.shape == null:
		spawnArea.shape = spawnShape
	if spawnTimer.wait_time != spawnTime:
		spawnTimer.wait_time = spawnTime

func _on_timer_timeout() -> void:
	if enemy.is_empty():
		push_error("No enemy selected for EnemySpawner", position)
		return
	
	var newEnemyPosition: Vector2 = createRandomPosition()
	
	if newEnemyPosition != Vector2(0, 0) and enemyContainer.get_children().size() < enemyLimit:
		var newEnemy = enemy.pick_random().instantiate()
		enemyContainer.add_child(newEnemy)
		
		newEnemy.global_position = newEnemyPosition


func createRandomPosition() -> Vector2:
	var randomOffset: Vector2 = Vector2(0, 0)
	var spawnAttempts: int = 0
	
	while true:
		spawnAttempts += 1
		if spawnShape is RectangleShape2D:
			var rect: Rect2 = spawnShape.get_rect()
			var random_x: float = randf_range(rect.position.x, rect.position.x + rect.size.x)
			var random_y: float = randf_range(rect.position.y, rect.position.y + rect.size.y)
			randomOffset = Vector2(random_x, random_y)
		elif spawnShape is CircleShape2D:
			randomOffset = Vector2.from_angle(randf_range(0, TAU)) * (spawnShape.radius * sqrt(randf()))
		
		var localRandomPosition = randomOffset+position
		var cellGridPosition = tilemap.local_to_map(localRandomPosition)
		var cell = tilemap.get_cell_tile_data(cellGridPosition)
		
		if cell and cell.get_custom_data("type") == "floor":
			var distanceToPlayer = (randomOffset+position).distance_squared_to(player.global_position)
			if distanceToPlayer >= 100*100:
				return randomOffset+position
			elif spawnAttempts > 20:
				break
	
	return Vector2(0, 0)
