extends Control
class_name Explosion

func explode(delay: float, rad: int = 0):
	$Sprite.set_light_mask(Globals.light_mask)
	$Light2D.set_item_cull_mask(Globals.light_mask)
	Globals.light_mask *= 2
	$Tween.interpolate_property($Sprite, "scale", Vector2.ZERO, Vector2.ONE * (1.5 + rad), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
	$Tween.interpolate_property($Light2D, "scale", Vector2.ZERO, Vector2.ONE * (1.5 + rad), 0.9, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
	$Tween.start()


func _on_Tween_tween_all_completed():
	Globals.light_mask /= 2
	queue_free()
