extends "res://Scripts/Bubble.gd"

class_name MultiColorBubble, "res://Sprites/Bubbles/0/left.png"

var color_index_left: int
var color_index_right: int

func _ready():
	randomize()
	color_index_left = round(rand_range(0, 5))
	color_index_right = round(rand_range(0, 5))
	color_index = color_index_left
	# the colors must not be equal
	while color_index_right == color_index_left:
		color_index_right = round(rand_range(0, 5))
	set_colors(Globals.themes[Globals.current_theme])
	set_decorations(Globals.decorations[Globals.current_decos])


func set_decorations(decorations: BubbleDecorations):
	match int(color_index_left):
		0:
			texture = decorations.red_bubble
			$RightHalf.texture = decorations.red_bubble_right
		1:
			texture = decorations.orange_bubble
			$RightHalf.texture = decorations.orange_bubble_right
		2:
			texture = decorations.yellow_bubble
			$RightHalf.texture = decorations.yellow_bubble_right
		3:
			texture = decorations.green_bubble
			$RightHalf.texture = decorations.green_bubble_right
		4:
			texture = decorations.lblue_bubble
			$RightHalf.texture = decorations.lblue_bubble_right
		5:
			texture = decorations.blue_bubble
			$RightHalf.texture = decorations.blue_bubble_right


func set_colors(theme: GameTheme):
	material = field.bubble_materials[color_index_left]
	$RightHalf.material = field.bubble_materials[color_index_right]
	$BlindMask.material.set("shader_param/color_to", theme.blind_bubble_color)


func check_combo(delay: float = 0):
	Globals.combo.append(self)
	is_in_chain = true
	destroy_delay = delay
	for bubble in field.get_node("Bubbles").get_children():
		if bubble.is_in_chain:
			continue
		if bubble_is_close(bubble.target_position_get()):
			if bubble.get_class() == "MultiColorBubble":
				if bubble.color_index_left == color_index_left or bubble.color_index_right == color_index_left or bubble.color_index_left == color_index_right or bubble.color_index_right == color_index_right:
					bubble.check_combo(delay + 0.1)
			elif bubble.color_index == color_index_left or bubble.color_index == color_index_right:
				bubble.check_combo(delay + 0.1)


func get_class(): return "MultiColorBubble"

