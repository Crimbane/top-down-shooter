extends Node

var pickupScene = preload("uid://b1v2i1jgbgqj2")

#var pickupSpawnTimer: int = 10 

var player
var tilemap: TileMapLayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	tilemap = get_tree().current_scene.get_node("Dungeon Map/BackgroundLayer")
	$"Buff Spawn Timer".timeout.connect(onSpawnBuffTimerTimeout)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#createPickup()
	#await get_tree().create_timer(pickupSpawnTimer).timeout
	pass


func spawnPickups() -> void:
	pass
	#if get_tree().paused:
	#while not get_tree().paused:
		#createPickup()
		#await get_tree().create_timer(pickupSpawnTimer).timeout


func createBuffPickup() -> void:
	var pickup = pickupScene.instantiate()
	
	var pickupTypes = ["Health", "Damage", "Shield", "Speed"]
	pickup.pickupSprite = pickupTypes.pick_random()
	
	var keepLooping = true
	var randomPosition: Vector2
	
	while keepLooping:
		var randomOffset = Vector2.from_angle(randf_range(0, TAU)) * randf_range(100, 200) # circle
		var localRandomPosition = player.position + randomOffset
		var cellGridPosition = tilemap.local_to_map(localRandomPosition)
		var cell = tilemap.get_cell_tile_data(cellGridPosition)
		if cell and cell.get_custom_data("type") == "floor":
			randomPosition = player.global_position + randomOffset
			keepLooping = false
	
	pickup.global_position = randomPosition
	
	get_parent().call_deferred("add_child", pickup)


func createAmmoPickup() -> void:
	var pickup = pickupScene.instantiate()
	
	var pickupTypes = ["Health", "Damage", "Shield", "Speed"]
	pickup.pickupSprite = pickupTypes.pick_random()
	
	var randomOffset = Vector2.from_angle(randf_range(0, TAU)) * randf_range(100, 200) # circle
	
	pickup.global_position = player.global_position + randomOffset
	
	get_parent().call_deferred("add_child", pickup)


func onSpawnBuffTimerTimeout() -> void:
	createBuffPickup()
