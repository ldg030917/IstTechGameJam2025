shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float smoothness : hint_range(0.01, 1.0) = 0.5;

void fragment() {
    // [수정됨] dist가 0.0 ~ 1.0 범위를 갖도록 0.7071로 나눠줍니다.
    float dist = distance(UV, vec2(0.5)) / 0.7071;

    float alpha = smoothstep(radius, radius + smoothness, dist);
    COLOR = vec4(shadow_color.rgb, alpha);
}