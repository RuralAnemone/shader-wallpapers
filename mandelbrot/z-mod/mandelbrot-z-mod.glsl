#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform float time;
uniform vec4 mouse;
uniform vec4 date;

// works on shadertoy
// now I just have to port it over to my phone and edit the offset (:

// based on https://www.shadertoy.com/view/ttGfDG

int mod(int a, int b) {
	// I think this is how this works
	if (b < 1) return 0;
	if (a < b) return a;

	// keep subtracting b from a until a < b; return a
	while (a >= b) a -= b;
	return a;
}

vec3 paletteAtIndex(int i) {
	vec3 palette0 = vec3( 0.5, 1.0, 1.0 );
	vec3 palette1 = vec3( 1.0, 0.5, 1.0 );
	vec3 palette2 = vec3( 1.0, 1.0, 0.5 );
	vec3 palette3 = vec3( 0.0, 0.0, 0.0 );
	vec3 palette4 = vec3( 0.5, 0.5, 0.5 );
	vec3 palette5 = vec3( 1.0, 0.5, 0.5 );
	vec3 palette6 = vec3( 0.5, 1.0, 0.5 );
	vec3 palette7 = vec3( 0.5, 0.5, 1.0 );

	if (i == 0) return palette0;
	if (i == 1) return palette1;
	if (i == 2) return palette2;
	if (i == 3) return palette3;
	if (i == 4) return palette4;
	if (i == 5) return palette5;
	if (i == 6) return palette6;
	if (i == 7) return palette7;

	else return vec3(0,0,0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    float depth = 16.0;
    float scale = .5;
    vec2 offset = vec2(1.165,-2.3);


    float aspectRatio = resolution.x / resolution.y;
    vec2 uv = fragCoord/resolution.xy;
    float re0 = scale * 2.0 * (2.0 * (fragCoord.y /resolution.x) - 1.0) + offset.y;
    float im0 = scale * 2.0 * (1.0/aspectRatio) * (2.0 * (fragCoord.x /resolution.y) - 1.0) + offset.x;

    bool diverged = false;
    float re = re0;
    float im = im0;

    im = im * sin(time/5.72);
    re = re * sin(time/10.);

    int i;
    for (i = 0; i < 100; ++i) {
        if (re*re + im*im > 2000.0) {
            diverged = true;
            break;
        }
        float retemp = re*re - im*im + re0;
        im = 2.0*re*im + im0;
        re = retemp;
    }

    vec3 col;

    if (diverged) {

        int nPalette = 8;

        float gradScale = 1.0;
        float smoothed = log2(log2(re*re+im*im) / 2.0);
        float fColorIndex = (sqrt(float(i) + 10.0 - smoothed) * gradScale);

        float colorLerp = fract(fColorIndex);
        colorLerp = colorLerp*colorLerp*(3.0-2.0*colorLerp);
        int colorIndexA = mod(int(fColorIndex), nPalette);
        int colorIndexB = mod((colorIndexA + 1), nPalette);

        col = mix(paletteAtIndex(colorIndexA), paletteAtIndex(colorIndexB), colorLerp);
    } else {
        col = vec3(0,0,0);
    }

    // Output to screen
    fragColor = vec4(col,1.0);
}

void main() {
	vec4 fragment_color;
	mainImage(fragment_color, gl_FragCoord.xy);
	gl_FragColor = fragment_color;
}
