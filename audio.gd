extends VBoxContainer

@export var master_slider: HSlider
@export var music_slider: HSlider
@export var sfx_slider: HSlider

const MIN_DB = -60.0
const MAX_DB = 0.0

func _ready():
	_sync_silder()
	
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _sync_silder():
	master_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	music_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))	
	sfx_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

func _slider_to_db(value: float) -> float:
	if value <= 0.0:
		return MIN_DB
		
	var linear = value/100.0
	var db = linear_to_db(linear)
	return clamp(db, MIN_DB, MAX_DB)

func _db_to_slider(db: float) -> float:
	if db <= MIN_DB:
		return 0.0
	var linear = db_to_linear(db)
	return clamp(linear * 100.0, 0.0, 100.0)

func _set_volume(bus_name: String, value: float):
	var db = _slider_to_db(value)
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, db)
	AudioServer.set_bus_mute(bus_index, db <= MIN_DB)

func _on_master_volume_changed(value: float):
	_set_volume("Master", value)

func _on_music_volume_changed(value: float):
	_set_volume("Music", value)

func _on_sfx_volume_changed(value: float):
	_set_volume("SFX", value)
