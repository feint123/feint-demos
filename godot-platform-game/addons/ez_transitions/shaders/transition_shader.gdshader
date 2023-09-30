shader_type canvas_item;

uniform vec2 screen_size = vec2(1920, 1080);

uniform float progress : hint_range(0,1) = 0;
uniform float pixel_size = 15.0;

uniform int type : hint_range(0,3) = 0;
uniform bool reversed = false;

void fragment() {
	//Tipo Diamante Pixel
	if (type == 0) {
		float xFraction = fract(FRAGCOORD.x / pixel_size);
		float yFraction = fract(FRAGCOORD.y / pixel_size);
		
		float xDistance = abs(xFraction - 0.5);
		float yDistance = abs(yFraction - 0.5);
		
		if (reversed) {
			if (xDistance + yDistance + UV.x + UV.y <= progress * 4.0) {
				discard;
			}
		} else {
			if (xDistance + yDistance + UV.x + UV.y > progress * 4.0) {
				discard;
			}
		}
	}
	//Tipo Circulo no Centro
	else if (type == 1) {
		float ratio = screen_size.x / screen_size.y;
		
		if (!reversed) {
			if (distance(vec2(0.5), vec2(mix(vec2(0.5).x, UV.x, ratio), UV.y)) <= 1.5 * (1.0 - progress)) {
				COLOR.a = 0.0;
			}
		} else {
			if (distance(vec2(0.5), vec2(mix(vec2(0.5).x, UV.x, ratio), UV.y)) > 1.5 * (1.0 - progress)) {
				COLOR.a = 0.0;
			}
		}
	}
	//Tipo Corte Vertical
	else if (type == 2) {
		if (reversed) {
			if (distance(vec2(0.5, 0.5), vec2(UV.x, UV.x)) >= 1.0 * (1.0 - progress)) {
				COLOR.a = 0.0;
			}
		} else {
			if (distance(vec2(0.5, 0.5), vec2(UV.x, UV.x)) < 1.0 * (1.0 - progress)) {
				COLOR.a = 0.0;
			}
		}
	}
	
	//Tipo Corte Horizontal
	else if (type == 3) {
		if (reversed) {
			if (distance(vec2(0.5, 0.5), vec2(UV.y, UV.y)) >= 1.0 * (1.0 - progress)) {
				COLOR.a = 0.0;
			}
		} else {
			if (distance(vec2(0.5, 0.5), vec2(UV.y, UV.y)) < 1.0 * (1.0 - progress)) {
				COLOR.a = 0.0;
			}
		}
	}
	
	//Tipo Fade
	else if (type == 4) {
		if (reversed) {
			COLOR.a = 1.0 - progress;
		} else {
			COLOR.a = progress;
		}
	}
}
