extends Area2D

var damage_timer: Timer

func _ready():
	# สร้าง Timer สำหรับ Damage Over Time
	damage_timer = Timer.new()
	damage_timer.wait_time = 0.5     # ทำดาเมจทุก 0.5s
	damage_timer.one_shot = false
	damage_timer.autostart = false
	add_child(damage_timer)

	damage_timer.connect("timeout", Callable(self, "_do_damage"))


var current_player = null


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody"):
		current_player = area.get_parent()

		if not current_player.is_in_group("safe"):
			current_player.SPEED -= 20

			# เริ่ม Damage Over Time
			damage_timer.start()

	print("you in lava")


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerBody"):
		var player = area.get_parent()

		if not player.is_in_group("safe"):
			player.SPEED += 20

		# หยุด DOT เมื่อออก
		damage_timer.stop()
		current_player = null

	print("you out lava")


# ฟังก์ชันทำดาเมจซ้ำ ๆ ทุกครั้งที่ timer timeout
func _do_damage():
	if current_player == null:
		return

	if current_player.is_in_group("safe"):
		return

	if not current_player.is_invincible:
		current_player.health -= 10
		print("DOT damage! HP =", current_player.health)
