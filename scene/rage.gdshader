shader_type canvas_item;

// --- 1. 설정 ---
uniform vec4 effect_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float effect_radius = 0.05;
uniform float effect_smoothness = 0.4;

uniform float sun_main_radius = 0.6; // 뾰족한 꼭짓점의 반지름
uniform float inner_radius_factor = 0.8; // 안쪽 둥근 골짜기의 반지름
uniform int num_points = 10;

uniform float rotation_speed = 2.0;
uniform float rotation_offset_degrees = 45.0;

// --- 2. 헬퍼 함수 ---
vec2 rotate(vec2 uv, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
}

// [수정됨] 뾰족한 꼭짓점(r_outer)과 둥근 골짜기(r_inner)를 가진 SDF
float sdf_star(vec2 p, int n, float r_inner, float r_outer) {
	float angle = atan(p.y, p.x);
	float r = length(p);
	
	float sector_angle = 2.0 * PI / float(n);
	float half_sector = 0.5 * sector_angle;
	
	// angle_in_sector: 0 (꼭짓점) ~ half_sector (골짜기)
	float angle_in_sector = mod(angle, sector_angle) - half_sector;
	angle_in_sector = abs(angle_in_sector);

	// normalized_angle: 0.0 (꼭짓점) ~ 1.0 (골짜기)
	float normalized_angle = angle_in_sector / half_sector;

	// wave: 0.0 (꼭짓점) ~ 1.0 (골짜기)
	// pow(..., 0.5) = sqrt(). 꼭짓점(0.0)을 뾰족하게, 골짜기(1.0)를 둥글게
	float wave = pow(normalized_angle, 0.5); 
	
	// r_outer(꼭짓점)에서 r_inner(골짜기)로 보간
	float r_at_angle = mix(r_outer, r_inner, wave);
	
	return r - r_at_angle; // < 0 이면 안쪽
}

// --- 3. 프래그먼트 쉐이더 ---
void fragment() {
	vec2 uv_centered = UV - vec2(0.5);
	float dist_from_center = length(uv_centered) / 0.7071;
	
	// --- A. 배경 그라데이션 (빨강 -> 투명) ---
	float alpha_bg = 1.0 - smoothstep(effect_radius, effect_radius + effect_smoothness, dist_from_center);

	// --- B. 태양 모양 ---
	float r_outer = sun_main_radius;
	float r_inner = sun_main_radius * inner_radius_factor;

	// 태양 1
	float rot1 = TIME * rotation_speed;
	vec2 uv1 = rotate(uv_centered, rot1);
	float sun_dist_1 = sdf_star(uv1, num_points, r_inner, r_outer);

	// 태양 2
	float rot2 = -TIME * rotation_speed + (rotation_offset_degrees * PI / 180.0);
	vec2 uv2 = rotate(uv_centered, rot2);
	float sun_dist_2 = sdf_star(uv2, num_points, r_inner, r_outer);

	float sun_grad_1 = 1.0 - smoothstep(-r_outer, -0.1, sun_dist_1);
	float sun_grad_2 = 1.0 - smoothstep(-r_outer, -0.1, sun_dist_2);
	
	// 두 태양의 그라데이션을 "더함"
	float sun_grad_combined = max(sun_grad_1, sun_grad_2);
	
	float final_alpha = 1.0 - (1.0 - alpha_bg) * (1.0 - sun_grad_combined);
	
	COLOR = vec4(effect_color.rgb, final_alpha * effect_color.a);
}