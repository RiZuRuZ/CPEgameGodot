extends Node2D

@export var speed: float = 60.0
@export var target_path: NodePath  # assign this to the Soldier in the editor

var target: Node2D
var animation: AnimationPlayer
var sprite: Sprite2D

func _ready():
	if target_path != null:
		target = get_node(target_path)
	
	# Get nodes
	if has_node("AnimationSlime"):
		animation = $AnimationSlime
	if has_node("Slime"):
		sprite = $Slime

func _physics_process(delta):
	if target == null:
		return

	var direction = target.global_position - global_position
	var distance = direction.length()

	if distance > 10:
		direction = direction.normalized()
		global_position += direction * speed * delta
		
		# Play walk animation
		if animation:
			animation.play("walk")

		# Flip horizontally
		if sprite:
			sprite.flip_h = direction.x < 0
	else:
		# Determine whether player is up/down or left/right
		if abs(direction.x) > abs(direction.y):
			# Player is more to the left/right
			if animation:
				animation.play("attack1")
		else:
			# Player is more above/below
			if animation:
				animation.play("attack2")
