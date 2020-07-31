shader_type canvas_item;
uniform vec4 color_to : hint_color;
uniform float time;

void fragment() {
	vec4 _tex = texture(TEXTURE, UV);
	vec2 uv = UV;
	uv.x -= 0.5;
	uv.x *= time;
	if (distance(uv, vec2(0.0, 0.5)) > 0.55 * time) {
	COLOR.rgb = color_to.rgb * _tex.rgb;
	COLOR.a = _tex.a;
	} else COLOR = vec4(0.0);
}