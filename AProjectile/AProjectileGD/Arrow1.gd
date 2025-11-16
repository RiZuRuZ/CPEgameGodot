extends Area2D

@export var range: float = 500.0
@export var speed: float = 400.0
@export var damage: int = 30
@export var lifetime: float = range/speed 
#t=s/v
var direction: Vector2 = Vector2.ZERO


func _ready():
	# เริ่มตัวจับเวลา auto delete
	_start_lifetime_timer()


func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyBody"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()


func setup(dir: Vector2):
	# ตั้งทิศของลูกศร
	direction = dir.normalized()

	# หมุน sprite ตามทิศ
	rotation = direction.angle()


func _start_lifetime_timer() -> void:
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()
