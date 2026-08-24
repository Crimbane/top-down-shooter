extends CharacterBody2D

var path: Array[Vector2i]
var pathIndex: int = 1
# Enemy sizes: Small is 16x16 collision or smaller. Medium is up to 32x32
@export_enum("Small", "Medium") var enemySize: String = "Small":
	set(value):
		enemySize = value


@export var speed: int = 40
const REPATH_TIME = 0.2
var targetDistance = 2

@onready var player = get_tree().current_scene.get_node("Player")
@onready var pathfinding = get_tree().current_scene.get_node("Pathfinding")




func _ready() -> void:
	repathLoop()

func _physics_process(_delta: float) -> void:
	followPath()

func calculatePath() -> void:
	path = pathfinding.calculatePath(global_position, player.global_position, enemySize)
	pathIndex = 1
	
	#print(path)


func followPath() -> void:
	if path.is_empty() or pathIndex >= path.size():
		velocity = Vector2.ZERO
		return
	
	var targetTile = path[pathIndex]
	
	var targetPosition = pathfinding.tilemap.to_global(pathfinding.tilemap.map_to_local(targetTile))
	
	if global_position.distance_to(targetPosition) < targetDistance:
		pathIndex += 1
		return
	
	velocity = global_position.direction_to(targetPosition) * speed
	
	move_and_slide()


func repathLoop() -> void:
	while true:
		calculatePath()
		await get_tree().create_timer(REPATH_TIME).timeout
