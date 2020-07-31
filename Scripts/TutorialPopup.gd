extends ColorRect
class_name TutorialPopup

signal exited


func _ready() -> void:
	rect_pivot_offset = rect_size * 0.5
	$Tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.1, Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _on_Button_pressed() -> void:
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.set_wait_time(0.3)
	$Timer.start()
	emit_signal("exited")
