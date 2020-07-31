extends Resource
class_name GameTheme

export (int) var id: int
export (int) var cost: int
export (int, "Coins", "Gems", "Real") var currency: int

export (Color) var bg_color: Color
export (Color) var bg_front_color: Color
export (Color) var bounds_color: Color
export (Color) var borderline_color: Color
export (Color) var button_color: Color
export (Color) var title_back: Color
export (Color) var title_front: Color
export (Color) var play_button_back: Color
export (Color) var play_button_front: Color
export (Color) var header_color: Color
export (Color) var button_text_color: Color
export (Color) var paragraph_color: Color
export (Color) var blind_bubble_color: Color

export (Array, Color) var bubble_colors: Array
export (Array, Color) var bubble_front_colors: Array
