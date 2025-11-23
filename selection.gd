extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/soldier.pivot_offset = Vector2($VBoxContainer/soldier.size.x/2,$VBoxContainer/soldier.size.y/2)
	$VBoxContainer/swordman.pivot_offset = Vector2($VBoxContainer/swordman.size.x/2,$VBoxContainer/swordman.size.y/2)
	$swordman.visible=false
	$soldier.visible=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$swordman/AnimationPlayer.play("idel")
	$soldier/AnimationPlayer.play("idel")


func _on_swordman_pressed() -> void:
	$"/root/Wave".selection = 1
	get_tree().change_scene_to_file("res://main.tscn")


func _on_soldier_pressed() -> void:
	$"/root/Wave".selection = 0
	get_tree().change_scene_to_file("res://main.tscn")


func _on_swordman_mouse_entered() -> void:
	$VBoxContainer/swordman.scale = Vector2(1.2,1.2)
	$swordman.visible=true

func _on_soldier_mouse_entered() -> void:
	$VBoxContainer/soldier.scale = Vector2(1.2,1.2)
	$soldier.visible=true

func _on_soldier_mouse_exited() -> void:
	$VBoxContainer/soldier.scale = Vector2(1,1)
	$soldier.visible=false

func _on_swordman_mouse_exited() -> void:
	$VBoxContainer/swordman.scale = Vector2(1,1)
	$swordman.visible=false
