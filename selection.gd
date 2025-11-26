extends Control

var player = 0
var tween :Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer2/soldier.pivot_offset = Vector2($VBoxContainer2/soldier.size.x/2,$VBoxContainer2/soldier.size.y/2)
	$VBoxContainer/swordman.pivot_offset = Vector2($VBoxContainer/swordman.size.x/2,$VBoxContainer/swordman.size.y/2)
	#$swordman.visible=false
	#$soldier.visible=false
	$Camera2D.position.x = $swordman.position.x-173
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$swordman/AnimationPlayer.play("idel")
	$soldier/AnimationPlayer.play("idel")
	if player%2 == 0 and $Camera2D.position.x != $swordman.position.x-173:
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($swordman.position.x-173,320),1)
	elif player%2 == 1 and $Camera2D.position.x != $soldier.position.x-173:
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($soldier.position.x-173,320),1)


func _on_swordman_pressed() -> void:
	$"/root/Wave".selection = 1
	get_tree().change_scene_to_file("res://main.tscn")


func _on_soldier_pressed() -> void:
	$"/root/Wave".selection = 0
	get_tree().change_scene_to_file("res://main.tscn")


func _on_swordman_mouse_entered() -> void:
	$VBoxContainer/swordman.scale = Vector2(1.2,1.2)
	#$swordman.visible=true

func _on_soldier_mouse_entered() -> void:
	$VBoxContainer2/soldier.scale = Vector2(1.2,1.2)
	#$soldier.visible=true

func _on_soldier_mouse_exited() -> void:
	$VBoxContainer2/soldier.scale = Vector2(1,1)
	#$soldier.visible=false

func _on_swordman_mouse_exited() -> void:
	$VBoxContainer/swordman.scale = Vector2(1,1)
	#$swordman.visible=false


func _on_next_butt_pressed() -> void:
	player += 1


func _on_prevbutt_pressed() -> void:
	player -=1
