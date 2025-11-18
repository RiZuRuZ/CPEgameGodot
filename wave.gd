extends CanvasLayer
var wave = 0
var nextwave: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$Label.text = "wave" + str(wave)
	$time.text = "Next Wave: " + str(nextwave) + " s"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text = "wave" + str(wave)
	$time.text = "Next Wave: " + str(nextwave) + " s"
