// from https://github.com/RuralAnemone/shader-wallpapers/blob/main/mandelbrot/z-mod/mandelbrot-z-mod.glsl

// works on shadertoy
// now I just have to port it over to my phone and edit the offset (:

// based on https://www.shadertoy.com/view/ttGfDG

const vec3 palette[ 8 ] = vec3[8](
                                vec3( 0.5, 1.0, 1.0 ),
                                vec3( 1.0, 0.5, 1.0 ),
                                vec3( 1.0, 1.0, 0.5 ),
                                vec3( 0.0, 0.0, 0.0 ),
                                vec3( 0.5, 0.5, 0.5 ),
                                vec3( 1.0, 0.5, 0.5 ),
                                vec3( 0.5, 1.0, 0.5 ),
                                vec3( 0.5, 0.5, 1.0 ));


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    float depth = 16.0;
    float scale = 1.5;
    vec2 offset = vec2(0.0,-2.0);


    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = fragCoord/iResolution.xy;
    float re0 = scale * 2.0 * (2.0 * (fragCoord.x /iResolution.x) - 1.0) + offset.y;
    float im0 = scale * 2.0 * (1.0/aspectRatio) * (2.0 * (fragCoord.y /iResolution.y) - 1.0) + offset.x;

    bool diverged = false;
    float re = re0;
    float im = im0;
    
    im = im * sin(iTime/5.72);
    re = re * sin(iTime/10.);
    // a little bit offset so it "doesn't repeat"
    
    int i;
    for (i = 0; i < 200; ++i) {
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
        int colorIndexA = int(fColorIndex) % nPalette;
        int colorIndexB = (colorIndexA + 1) % nPalette;

        col = mix(palette[colorIndexA], palette[colorIndexB], colorLerp);
    } else {
        col = vec3(0,0,0);
    }

    // Output to screen
    fragColor = vec4(col,1.0);
}
