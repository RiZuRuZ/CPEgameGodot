extends Node2D

#const PlayerScene = preload("res://Animation5+3/Priest.tscn")
const PlayerScene = preload("res://Animation5+3/Soldier.tscn")
func _ready() -> void:
	var player = PlayerScene.instantiate()
	add_child(player)
	player.add_to_group("player")
	player.position = Vector2(400, 300)

	# optional if your scene structure matches
	#player.gfx_path = "CharacterBody2D/Soldier"
	#player.anim_path = "CharacterBody2D/AnimationPlayer"
