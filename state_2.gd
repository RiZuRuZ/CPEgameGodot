extends Node2D

var PlayerScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print($"/root/Wave".selection)
	if $"/root/Wave".selection == 0:
		PlayerScene = preload("res://Animation5+3/Soldier.tscn")
		print("sol")
	if $"/root/Wave".selection == 1:
		PlayerScene = preload("res://Animation5+3/Swordman.tscn")
		print("sword")
	elif $"/root/Wave".selection == 2:
		PlayerScene = preload("res://Animation5+3/Armored Axeman.tscn")
		print($"/root/Wave".selection)

	var player = PlayerScene.instantiate()
	add_child(player)
	var player_nodes = get_tree().get_nodes_in_group("player")
	
	# Check if there is more than one player (i.e., the Swordman and the Soldier)
	if player_nodes.size() > 1:
		# Loop through all nodes in the 'player' group
		for node in player_nodes:
			# Check if this node is NOT the one we just created (the Swordman)
			if node != player:
				# Assuming the redundant node is the Soldier, remove it.
				node.queue_free()
				print("Deleted redundant player instance (likely Soldier).")
	#player.add_to_group("player")
	#player.position = Vector2(250, 150)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
