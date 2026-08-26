extends CharacterBody2D

var path: Array[Vector2i]
var pathIndex: int = 1
const REPATH_TIME: float = 0.2
var targetDistance: int = 2
var chasingPlayer: bool = true

# Enemy sizes: Small is 16x16 collision or smaller. Medium is up to 32x32
@export_enum("Small", "Medium") var enemySize: String = "Small":
	set(value):
		enemySize = value

@export var speed: int = 40

@onready var player = get_tree().current_scene.get_node("Player")
@onready var pathfinding = get_tree().current_scene.get_node("Pathfinding")
@onready var raycast = $"Line Of Sight Ray"





func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	$"Line Of Sight Timer".timeout.connect(onLOSTimerTimeout)
	calculatePath()
	repathLoop()

func _physics_process(_delta: float) -> void:
	raycast.target_position = to_local(player.global_position)
	raycast.force_raycast_update()
	
	if raycast.is_colliding() and raycast.get_collider().is_in_group("Player"):
		if $"Line Of Sight Timer".is_stopped():
			$"Line Of Sight Timer".start()
	else:
		$"Line Of Sight Timer".stop()
		chasingPlayer = false
		
	if chasingPlayer == true:
		chasePlayer()
	else:
		followPath()


func onLOSTimerTimeout() -> void:
	chasingPlayer = true


func chasePlayer() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()


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
		if not chasingPlayer:
			calculatePath()
		await get_tree().create_timer(REPATH_TIME).timeout
