extends Area2D

var damage_timer: Timer
var current_player = null

func _ready():
	damage_timer = Timer.new()
	damage_timer.wait_time = 0.2    # damage ทุก 0.2 วิ
	damage_timer.one_shot = false
	add_child(damage_timer)
	damage_timer.connect("timeout", Callable(self, "_do_damage"))


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("foot"):
		current_player = area.get_parent()

		# ถ้าไม่ safe → slow & damage ทันที
		if not current_player.is_in_group("safe"):
			_apply_slow()
			_apply_damage()

			# เริ่ม Damage Over Time
			damage_timer.start()

	print("enter lava")


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("foot"):

		# หยุดทำ damage
		damage_timer.stop()

		# คืนความเร็ว หากเคยโดน slow จาก lava
		if current_player != null and current_player.has_meta("lava_slowed"):
			current_player.SPEED += 20
			current_player.remove_meta("lava_slowed")

		current_player = null

	print("exit lava")


func _do_damage():
	if current_player == null:
		return
	if current_player.is_in_group("safe"):
		return
	if current_player.is_invincible:
		return

	_apply_damage()


func _apply_slow():
	if not current_player.has_meta("lava_slowed"):
		current_player.SPEED -= 20
		current_player.set_meta("lava_slowed", true)


func _apply_damage():
	if not current_player.is_invincible:
		current_player.health -= 10
		print("Damage! HP =", current_player.health)
