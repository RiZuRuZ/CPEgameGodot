extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody"):
		var player = area.get_parent()
		player.add_to_group("safe")
		print("SAFE ENTERED --- player groups:", player.get_groups())


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerBody"):
		var player = area.get_parent()
		player.remove_from_group("safe")
		print("SAFE EXIT --- player groups:", player.get_groups())
