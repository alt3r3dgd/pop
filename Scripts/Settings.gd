extends Control
class_name Settings, "res://Sprites/Icons/settings.png"

signal back_pressed

export (Array, String) var difficulty_descs

func _ready():
	rect_pivot_offset = rect_size * 0.5
	$Sound.min_value = 0.0001
	$Sound.step = 0.0001
	$Sound.value = Globals.volume
	$Difficulty.value = Globals.difficulty
	$DifficultyDesc.text = difficulty_descs[Globals.difficulty]
	set_game_theme(Globals.themes[Globals.current_theme])

func _on_BackButton_pressed():
	$BackButton.disabled = true
	emit_signal("back_pressed")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		emit_signal("back_pressed")


func _on_YouTubeButton_pressed():
	OS.shell_open("https://www.youtube.com/channel/UC8G5egJVXHMoi-21vIJhKZg")


func _on_DiscordButton_pressed():
	OS.shell_open("https://discord.gg/CU4XUv3")


func _on_TwitterButton_pressed():
	OS.shell_open("https://twitter.com/alt3r3d")


func _on_PrivacyPolicy_pressed():
	OS.shell_open("https://alt3r3dgd.github.io/privacy-policy")


func _on_Sound_value_changed(value):
	Globals.volume = value


func _on_Difficulty_value_changed(value):
	Globals.difficulty = value
	$DifficultyDesc.text = difficulty_descs[value]


func set_game_theme(theme: GameTheme):
	$BackButton.self_modulate = theme.header_color
	$Title.set("custom_colors/font_color", theme.header_color)
	$SoundTitle.set("custom_colors/font_color", theme.header_color)
	$DifficultyTitle.set("custom_colors/font_color", theme.header_color)
	$DifficultyDesc.set("custom_colors/font_color", theme.paragraph_color)
	$Label2.set("custom_colors/font_color", theme.paragraph_color)
	$FollowAltered.set("custom_colors/font_color", theme.header_color)
