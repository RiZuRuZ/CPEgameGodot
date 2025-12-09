extends Control
var wave:int = 0
var nextwave: int = 0
var state = 2
var selection = -1
@onready var sfx_victiory: AudioStreamPlayer = $SFX_Victiory
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer.visible = false
	$CanvasLayer/Label.visible=false
	$CanvasLayer/time.visible=false
	$CanvasLayer/Button.visible = false
	$CanvasLayer/Label.text = "wave" + str(wave)
	$CanvasLayer/time.text = "Next Wave: " + str(nextwave) + " s"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	$CanvasLayer/Label.text = "wave" + str(wave)
	$CanvasLayer/time.text = "Next Wave: " + str(nextwave) + " s"
	
	if $CanvasLayer/victory.visible == true:
		sfx_victiory.play()
		$CanvasLayer/victory.text = "Stage" +str(state-1)+ "Complete!"
		await get_tree().create_timer(2).timeout
		var tweem = create_tween()
		tweem.tween_property($CanvasLayer/victory,"modulate",Color(modulate.r, modulate.g,modulate.b, 0.0),1)
		await tweem.finished
		$CanvasLayer/victory.visible = false
		$CanvasLayer/Button.visible = true

func _on_button_pressed() -> void:
	if state == 2:
		get_tree().change_scene_to_file("res://Ascenes/cutscene/cutsceneLV1.tscn")
		$CanvasLayer/Button.visible = false
	elif  state == 3:
		get_tree().change_scene_to_file("res://main_menu_fixed.tscn")
		$CanvasLayer/Button.visible = false
