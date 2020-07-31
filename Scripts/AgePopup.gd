extends ColorRect

var age: int = 0
var digits: int = 0

func _ready():
	rect_pivot_offset = rect_size * 0.5
	set_colors(Globals.get_current_theme())
	$Tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.1, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func set_colors(theme: GameTheme):
	$Panel.self_modulate = theme.bg_color
	$Panel/Title.set("custom_colors/font_color", theme.header_color)
	$Panel/Age.set("custom_colors/font_color", theme.header_color)
	$Panel/Disclaimer.set("custom_colors/font_color", theme.paragraph_color)

func _on_digit_entered(digit: int):
	if digits == 0 and digit == 0: return
	if digits == 3: return
	age *= 10
	age += digit
	digits += 1
	$Panel/Bkspc.disabled = false
	$Panel/Ok.disabled = false
	$Panel/Age.text = str(age)


func close():
	Globals.age = age
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.set_wait_time(0.3)
	$Timer.start()


func _on_Bkspc_pressed():
	age /= 10
	digits -= 1
	if age == 0:
		$Panel/Bkspc.disabled = true
		$Panel/Ok.disabled = true
	$Panel/Age.text = str(age)
