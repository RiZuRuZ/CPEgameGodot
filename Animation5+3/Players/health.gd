extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = str($"../Bar".value)+ "/"+ str($"../Bar".max_value)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str(int($"../Bar".value))+ "/"+ str(int($"../Bar".max_value))
