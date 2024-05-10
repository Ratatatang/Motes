shader_type canvas_item;

global uniform vec4 fireColor0;
global uniform vec4 fireColor1;
global uniform vec4 fireColor2;
global uniform vec4 fireColor3;

uniform vec4 new1 : source_color = vec4(0.00, 0.00, 0.00, 1.00);
uniform vec4 new2 : source_color = vec4(0.00, 0.00, 0.00, 1.00);
uniform vec4 new3 : source_color = vec4(0.00, 0.00, 0.00, 1.00);
uniform vec4 new4 : source_color = vec4(0.00, 0.00, 0.00, 1.00);

uniform bool enabled = true;

void fragment() {
	if (enabled)
		if (COLOR == fireColor0)
			COLOR = new1;
		else if (COLOR == fireColor1)
			COLOR = new2;
		else if (COLOR == fireColor2)
			COLOR = new3;
		else if (COLOR == fireColor3)
			COLOR = new4;
}