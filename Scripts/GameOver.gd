extends Control
class_name GameOver

export (Array, String) var game_over_messages

signal try_again_pressed
signal back_to_menu_pressed

func _ready():
	if Globals.difficulty == 0:
		$Score.visible = false
		$ScoreText.visible = false
	rect_pivot_offset = rect_size * 0.5
	$Message.text = "Nice." if $Score.text == "69" else game_over_messages[round(rand_range(0, game_over_messages.size() - 1))]
	set_game_theme(Globals.get_current_theme())
	$Sound.play()


func set_game_theme(theme: GameTheme):
	$Title.set("custom_colors/font_color", theme.header_color)
	$Message.set("custom_colors/font_color", theme.paragraph_color)
	$Score.set("custom_colors/font_color", theme.header_color)
	$ScoreText.set("custom_colors/font_color", theme.paragraph_color)
	pass


func _on_TryAgain_pressed():
	$TryAgain.disabled = true
	emit_signal("try_again_pressed")


func _on_BackToMenu_pressed():
	$BackToMenu.disabled = true
	emit_signal("back_to_menu_pressed")
