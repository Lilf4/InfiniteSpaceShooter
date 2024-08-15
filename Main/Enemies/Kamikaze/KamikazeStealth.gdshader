shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled;
//source_color
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;

uniform float dissolve_amount : hint_range(0,1);

uniform float scroll_speed : hint_range(0, 2) = 0.08;
uniform float angle_degrees : hint_range(0, 360) = 45.0;
uniform float repeat_x : hint_range(1, 20) = 20;
uniform float repeat_y : hint_range(1, 20) = 12;
uniform float row_offset : hint_range(0, 1) = 1;

void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	
	float angle_rad = radians(angle_degrees);

	vec2 direction = vec2(cos(angle_rad), sin(angle_rad));

	vec2 offset_uv = UV - (TIME * scroll_speed * direction);

	float offset = fract(floor(offset_uv.y * repeat_y) * 0.5) > 0.0 ? (row_offset * 0.324) : 0.0;

	offset_uv.x += offset;

	vec2 scaled_uv = vec2(fract(offset_uv.x * repeat_x), fract(offset_uv.y * repeat_y));

	vec2 texelSize = vec2(1.0) / vec2(textureSize(texture_albedo, 0));
	vec2 snappedUV = round(scaled_uv / texelSize) * texelSize;
	
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	EMISSION = texture(texture_albedo, snappedUV).rgb * albedo.rgb * albedo_tex.rgb;
	ALPHA = max(0, min(1, texture(texture_albedo, snappedUV).r + (dissolve_amount - 0.2)));
}