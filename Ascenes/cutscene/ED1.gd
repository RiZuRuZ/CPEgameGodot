extends Node2D

@onready var name_label = $UI/Panel/VBoxContainer/Label
@onready var dialogue_text = $UI/Panel/VBoxContainer/RichTextLabel
@onready var ending_image = $EndingImage

# -----------------------------
# GOOD END DIALOGUES
# -----------------------------
var dialogues = [
	{"name":"HERO","char":"HERO","text":"ในที่สุด… ทุกอย่างก็จบลงแล้ว"},
	{"name":"PRINCESS","char":"PRINCESS","text":"ผู้กล้า… เจ้ามาช่วยข้าได้จริงๆ"},
	{"name":"HERO","char":"HERO","text":"ข้าสัญญาแล้วว่าจะต้องพาเจ้ากลับบ้านให้ได้"},
	{"name":"PRINCESS","char":"PRINCESS","text":"ข้ากลัวเหลือเกินว่าจะไม่ได้พบเจ้าอีก…"},
	{"name":"HERO","char":"HERO","text":"ต่อจากนี้ ข้าจะไม่ปล่อยให้เจ้าเผชิญมันเพียงลำพังอีก"},
	{"name":"PRINCESS","char":"PRINCESS","text":"อื้ม… ถ้าอย่างนั้น… ขอให้ข้าอยู่เคียงข้างเจ้าได้ไหม"},
	{"name":"HERO","char":"HERO","text":"แน่นอน เจ้าหญิง"}
]

var current_index := 0
var typing_speed := 0.03
var is_typing := false
var full_text := ""
var displayed_text := ""

var ending_phase := false   # false = บทพูด / true = รูปฉากจบ

# -----------------------------
func _ready():
	ending_image.visible = false
	show_dialogue()

# -----------------------------
func show_character(name:String):
	for c in $character.get_children():
		c.visible = (c.name == name)

# -----------------------------
func show_dialogue():
	var data = dialogues[current_index]
	name_label.text = data.name
	show_character(data.char)

	full_text = data.text
	displayed_text = ""
	dialogue_text.text = ""
	is_typing = true
	type_text()

# -----------------------------
func type_text():
	for c in full_text:
		if not is_typing:
			break
		displayed_text += c
		dialogue_text.text = displayed_text
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	dialogue_text.text = full_text

# -----------------------------
func _input(event):
	if event.is_action_pressed("ui_accept"):

		# กำลังพิมพ์ → ข้าม
		if is_typing:
			is_typing = false
			dialogue_text.text = full_text
			return

		# หลังจบบทพูด → แสดงรูปฉากจบ
		if ending_phase:
			get_tree().change_scene_to_file("res://main_menu_fixed.tscn")
			return

		current_index += 1
		if current_index < dialogues.size():
			show_dialogue()
		else:
			show_ending_image()

# -----------------------------
func show_ending_image():
	ending_phase = true
	$UI.visible = false
	$character.visible = false
	ending_image.visible = true
