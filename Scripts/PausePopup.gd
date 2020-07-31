extends ColorRect
class_name PausePopup

signal quit_pressed

func _ready():
	rect_pivot_offset = rect_size * 0.5
	set_colors(Globals.get_current_theme())
	$Panel/Sound.min_value = 0.0001
	$Panel/Sound.step = 0.0001
	$Panel/Sound.value = Globals.volume
	$Tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.1, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func set_colors(theme: GameTheme):
	$Panel.self_modulate = theme.bg_color
	$Panel/Title.set("custom_colors/font_color", theme.header_color)
	$Panel/SoundTitle.set("custom_colors/font_color", theme.paragraph_color)


func _on_Resume_pressed():
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.set_wait_time(0.3)
	$Timer.start()
	get_tree().paused = false
	Globals.field_is_focused = true
	$Panel/Resume.disabled = true


func _on_Quit_pressed():
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.set_wait_time(0.3)
	$Timer.start()
	get_tree().paused = false
	emit_signal("quit_pressed")
	$Panel/Quit.disabled = true


func _on_Sound_value_changed(value: float) -> void:
	Globals.volume = value
