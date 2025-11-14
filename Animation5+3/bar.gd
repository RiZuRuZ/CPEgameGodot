extends ProgressBar
@onready var bar = $Bar
var health = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = health
	value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
