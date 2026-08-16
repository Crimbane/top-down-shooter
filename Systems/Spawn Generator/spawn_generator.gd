extends Node

var pickupScene = preload("uid://b1v2i1jgbgqj2")
var pickupSpawnTimer: int = 2

var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	spawnPickups()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func spawnTimer(timer: int) -> void:
	await get_tree().create_timer(timer).timeout
	

func spawnPickups() -> void:
	while true:
		createPickup()
		await get_tree().create_timer(pickupSpawnTimer).timeout


func createPickup() -> void:
	var pickup = pickupScene.instantiate()
	
	var pickupTypes = ["Health", "Damage", "Shield", "Speed"]
	pickup.pickupSprite = pickupTypes.pick_random()
	
	var randomOffset = Vector2.from_angle(randf_range(0, TAU)) * randf_range(100, 200) # circle
	
	pickup.global_position = player.global_position + randomOffset
	
	get_parent().call_deferred("add_child", pickup)
	
	spawnTimer(pickupSpawnTimer)
