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
	elif $"/root/Wave".selection == 3:
		PlayerScene = preload("res://Animation5+3/Archer.tscn")
		print($"/root/Wave".selection)
	var player = PlayerScene.instantiate()
	add_child(player)
	var player_nodes = get_tree().get_nodes_in_group("player")
	player.XP = $"/root/LevelSave".progress
	player.level = $"/root/LevelSave".level
	#player.add_to_group("player")
	#player.position = Vector2(250, 150)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
