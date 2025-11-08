shader_type canvas_item;

// 어둡게 만들 색상 (보통 검은색)
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// 원의 반지름 (0.0 ~ 1.0)
// 이 값을 조절해서 시야를 줄이거나 늘립니다.
uniform float radius : hint_range(0.0, 1.0) = 0.5;

// 그라데이션의 부드러움 (0.01 ~ 1.0)
// 0에 가까울수록 경계선이 날카로워집니다.
uniform float smoothness : hint_range(0.01, 1.0) = 0.5;

void fragment() {
    // 화면 중앙(0.5, 0.5)으로부터 현재 픽셀(UV)까지의 거리를 계산
    float dist = distance(UV, vec2(0.5));

    // smoothstep 함수로 부드러운 그라데이션 알파(불투명도) 값을 계산
    // dist가 radius보다 작으면 0.0 (투명)
    // dist가 radius + smoothness보다 크면 1.0 (불투명)
    // 그 사이는 부드럽게 보간됩니다.
    float alpha = smoothstep(radius, radius + smoothness, dist);

    // 최종 색상 출력: 어둡게 만들 색상에 계산된 알파 값을 적용
    COLOR = vec4(shadow_color.rgb, alpha);
}