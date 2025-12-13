extends Area2D

var damage_timer: Timer
var current_player = null


func _ready():
	# สร้าง Timer สำหรับ Damage Over Time
	damage_timer = Timer.new()
	damage_timer.wait_time = 0.2     # ทำดาเมจทุก 0.5s (ปรับได้)
	damage_timer.one_shot = false
	damage_timer.autostart = false
	add_child(damage_timer)
	damage_timer.connect("timeout", Callable(self, "_do_damage"))


func _process(delta):
	# ถ้ามี player อยู่ในพื้นที่ ให้ตรวจสถานะ safe/invincible แล้ว start/stop timer ตามจริง
	if current_player != null:
		# ถ้า player อยู่ใน safe → หยุด timer (ถ้ามันรันอยู่) และคืนสปีดถ้าชะลอไว้
		if current_player.is_in_group("safe"):
			if damage_timer.is_stopped() == false:
				damage_timer.stop()
			# คืน speed เฉพาะถ้าเคยชะลอโดย lava ตัวนี้
			if current_player.has_meta("lava_slowed"):
				current_player.SPEED += 20
				current_player.remove_meta("lava_slowed")
		else:
			# ถ้าไม่อยู่ safe → เรียกให้เริ่ม DOT ถ้ามันยังไม่รัน
			# และลด speed แค่ครั้งเดียวโดยใช้ meta
			if damage_timer.is_stopped():
				damage_timer.start()
			if not current_player.has_meta("lava_slowed"):
				current_player.SPEED -= 20
				current_player.set_meta("lava_slowed", true)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("foot"):
		# รับ reference player (parent ของ collider ที่ชน)
		current_player = area.get_parent()

		# ถ้าผู้เล่นไม่ได้อยู่ใน safe ให้ลดสปีดและเริ่ม DOT
		if not current_player.is_in_group("safe"):
			# ลด speed เพียงครั้งเดียว
			if not current_player.has_meta("lava_slowed"):
				current_player.SPEED -= 20
				current_player.set_meta("lava_slowed", true)

			# เริ่ม Timer (ถ้ายังไม่รัน)
			if damage_timer.is_stopped():
				damage_timer.start()

	print("you in lava")


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("foot"):
		# ถ้าผู้เล่นออกจาก lava ให้หยุด DOT และคืน speed ถ้าชะลอไว้
		if current_player != null:
			if current_player.has_meta("lava_slowed"):
				current_player.SPEED += 20
				current_player.remove_meta("lava_slowed")

		damage_timer.stop()
		current_player = null

	print("you out lava")


func _do_damage():
	# เช็คหลายชั้นก่อนทำ damage จริง
	if current_player == null:
		return

	# ถ้าเข้า safe ระหว่างรอ timeout ให้หยุด
	if current_player.is_in_group("safe"):
		return

	# ถ้าอมตะ ให้ข้าม
	if current_player.is_invincible:
		return

	# ทำ damage
	current_player.health -= 10
	print("DOT damage! HP =", current_player.health)
