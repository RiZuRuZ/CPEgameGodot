extends Control
var wave = 0
var nextwave: int = 0
var state = "he;;p"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer.visible = false
	$CanvasLayer/Label.text = "wave" + str(wave)
	$CanvasLayer/time.text = "Next Wave: " + str(nextwave) + " s"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CanvasLayer/Label.text = "wave" + str(wave)
	$CanvasLayer/time.text = "Next Wave: " + str(nextwave) + " s"
	
	if $CanvasLayer/victory.visible == true:
		$CanvasLayer/victory.text = "Stage" +str(state)+ "Complete!"
		await get_tree().create_timer(2).timeout
		var tweem = create_tween()
		tweem.tween_property($CanvasLayer/victory,"modulate",Color(modulate.r, modulate.g,modulate.b, 0.0),1)
		await tweem.finished
		$CanvasLayer/victory.visible = false
