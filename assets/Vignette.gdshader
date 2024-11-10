shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1); // Vignette color and strength
uniform float radius : hint_range(0.0, 1.0) = 0.60; // The radius of the vignette effect
uniform float softness : hint_range(0.0, 1.0) = 0.45; // How soft the vignette edges are

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5); // Screen center in normalized coordinates

    // Distance from the current fragment to the center of the screen
    float dist = distance(uv, center);

    // Calculate vignette effect
    float vignette = 1.0 - smoothstep(radius, radius - softness, dist);

    // Apply vignette color based on vignette strength
    vec4 vignette_color = mix(vec4(0), color, vignette);

    // Final output
    COLOR = texture(TEXTURE, UV) * vignette_color;
}
