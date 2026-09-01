class_name BaseEnemy
extends CharacterBody2D
#Enemy Area2D collision has to be slightly bigger in all directions. Can be less than 1 pixel

var path: Array[Vector2i]
var pathIndex: int = 1 # 0 is tile enemy is on
const REPATH_TIME: float = 0.2
var targetDistance: int = 2
var chasingPlayer: bool = true
var pathfindingBecauseStuck = false

# Enemy sizes: Small is 16x16 collision or smaller. Medium is up to 32x32
@export_enum("Small", "Medium") var enemySize: String = "Medium":
	set(value):
		enemySize = value

@export var speed: int = 40
@export var maxHealth: int = 100
var currentHealth: int = maxHealth
@export var attackDamage: int = 1

@onready var baseSpeed: int
@onready var baseMaxHealth: int

@export var killScore: int = 1
@onready var baseKillScore: int


@onready var player = get_tree().get_first_node_in_group("Player")
@onready var pathfinding = get_tree().current_scene.get_node("%Pathfinding")
@onready var raycast = $"Line Of Sight Ray"

@onready var healthBar = $"TextureProgressBar"
@onready var collisionShape = $CollisionShape2D
var healthBarSizeHeight = 20
var healthBarOffsetHeight = 3

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	$"Line Of Sight Timer".timeout.connect(onLOSTimerTimeout)
	
	
	$"Area2D Attack".body_entered.connect(attack)
	$"Area2D Pathfinding".body_entered.connect(changePathfindingOnStuck)
	
	baseSpeed = speed
	baseMaxHealth = maxHealth
	baseKillScore = killScore
	
	killScore = int(baseKillScore * GameManager.difficultyMultiplier)
	speed = int(baseSpeed * GameManager.difficultyMultiplier)
	if speed > 155:
		speed = 155
	
	maxHealth = int(baseMaxHealth * GameManager.difficultyMultiplier)
	currentHealth = maxHealth
	
	placeHealthBar()
	
	call_deferred("startEnemyPathing")

func _process(_delta) -> void:
	animations()


func _physics_process(_delta: float) -> void:
	movement()


func placeHealthBar() -> void:
	healthBar.max_value = maxHealth
	healthBar.value = currentHealth
	if collisionShape.shape is RectangleShape2D:
		var collisionSizeWidth = collisionShape.shape.size.x
		var collisionSizeHeight = collisionShape.shape.size.y
		healthBar.size = Vector2(collisionSizeWidth, healthBarSizeHeight)
		
		healthBar.position.x = -healthBar.size.x / 2
		healthBar.position.y = -collisionSizeHeight / 2 - healthBar.size.y - healthBarOffsetHeight


func attack(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.takeDamage(attackDamage)


func changePathfindingOnStuck(body: Node2D) -> void:
	if body.is_in_group("World"):
		pathfindingBecauseStuck = true
		$"Line Of Sight Timer".stop()
		chasingPlayer = false
		await get_tree().create_timer(REPATH_TIME).timeout
		pathfindingBecauseStuck = false


func takeDamage(damage: int) -> void:
	currentHealth -= damage
	
	if currentHealth <= 0:
		die()
	
	healthBar.value = currentHealth
	healthBar.visible = true


func die() -> void:
	GameManager.playMonsterDeathSound()
	if not get_tree().current_scene.name == "Controls":
		GameManager.increaseScore(killScore)
	queue_free()


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


func movement() -> void: # moved from physics process
	#print("chasing player: ", chasingPlayer)
	if pathfindingBecauseStuck == false:
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
	else:
		followPath()


func repathLoop() -> void:
	while true:
		if not chasingPlayer:
			calculatePath()
		await get_tree().create_timer(REPATH_TIME).timeout


func startEnemyPathing() -> void:
	calculatePath()
	repathLoop()


func animations() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.animation = "move"
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = "move"
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
