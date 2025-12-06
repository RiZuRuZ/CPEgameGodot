extends Area2D

@export var range: float = 100
var speed: float
@export var damage: int = 30
var lifetime: float = 0.8
#t=s/v
var direction: Vector2 = Vector2.ZERO
var check =0

func _ready():
	# เริ่มตัวจับเวลา auto delete
	speed = range/lifetime
	_start_lifetime_timer()
	$AnimationPlayer.play("anim")
	

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyBody"):
		area.get_parent().health -= damage
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
