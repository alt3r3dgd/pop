extends TextureButton

var color = .get_modulate()

func _ready():
	.set_pivot_offset(.get_size() * 0.5)


func _on_TextureButton_button_down():
	$Tween.interpolate_property(self, "rect_scale", .get_scale(), Vector2.ONE * 0.9, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", .get_modulate(), color.darkened(0.1), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _on_TextureButton_button_up():
	$Tween.interpolate_property(self, "rect_scale", .get_scale(), Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", .get_modulate(), color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
