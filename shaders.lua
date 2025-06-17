
--[[
    -- REF : 
    -- https://cs.nyu.edu/~perlin/courses/fall2005ugrad/phong.html
    -- https://www.youtube.com/watch?v=BkxN2pwwRPM
    -- https://www.youtube.com/shorts/UkGaAxvHouI
    -- https://love2d.org/wiki/Tutorial:Introduction_to_Shaders
    -- https://blogs.love2d.org/content/beginners-guide-shaders
    -- https://shader-tutorial.dev/basics/vertex-shader/
    -- https://registry.khronos.org/OpenGL-Refpages/gl4/html/smoothstep.xhtml
    -- https://learnopengl.com/Lighting/Light-casters
    -- https://learnopengl.com/Lighting/Multiple-lights
    
    There are 2 kinds of shaders:
    
    1) Fragment Shaders (Pixel Shaders): 
       These shaders are used to compute the color of each pixel on the screen. 
       (So they shader's code will be executed for every pixel on the screen.)
       They take the output from vertex shaders and apply effects like lighting, shadows, and color adjustments.

    2) Vertex Shaders: 
         These shaders are used to transform the vertices of 3D models into 2D screen coordinates.
         They handle the geometry of the scene, such as transforming positions, normals, and texture coordinates.
         (So they shader's code will be executed for every vertex in the scene.)

    In this game, we will use a fragment shader to simulate lighting effects on the game world.
    The shader will take the light sources and apply their effects on the pixels of the game world.


    Shaders in Löve are written in GLSL (OpenGL (Open Graphics library) Shading Language).
    But with a few modifications, Löve uses a custom shader language that is similar to GLSL but has some differences.
    The differences include:
    GLSL vs Löve Shader Language:
        
        1)  In GLSL, the `main` function is the entry point for the shader.
            In Löve, the `effect` function is the entry point for the shader.
        
        2)  In GLSL, the 'float' type is used for floating-point numbers.
            In Löve, the 'number' type is used for floating-point numbers.

        3)  In GLSL, the `texture2D` function is used to sample a texture.
            In Löve, the `Texel` function is used to sample a texture.

        4)  In GLSL, the 'uniform' keyword is used to declare uniform variables.
            In Löve, the 'extern' keyword is used to declare uniform variables.

        5)  In GLSL, the 'sampler2D' type is used to declare a texture.
            In Löve, the 'Image' type is used to declare a texture.

    The 'effect' function in Löve is similar to the 'main' function in GLSL.
    The 'effect' function takes the following parameters:
        
        - color:        
        --------
            A vec4 (vector with 4 floats) 
            the color set during love.graphics.setColor
        
        - image:
        --------
            The Image/Texture being processed by the shader.
        
        - texture_coords:
        -----------------
            A vec2 (vector with 2 floats) 
            coordinates/the position of the pixel being processed , 
            normalized (so a value between [0 ; 1]) , 
            relative to the image.

        - screen_coords: 
        ----------------
            A vec2 (vector with 2 floats) 
            coordinates/the position of the pixel being processed , 
            relative to the screen.

    General workflow of a shader in Löve:
    
        1)  The shader is loaded using love.graphics.newShader(shader_code).
        2)  The shader receives the variables using shader:send(<name of variable>,value).
            Communication between CPU and GPU is generally expensive. 
            You don''t want to be sending hundreds of variables per frame

        3)  The shader is set using love.graphics.setShader(shader).
        4)  Pass dynamic variables to the shader using shader:send(<name of variable>,value).
            These variables can be updated every frame, such as the number of lights, their positions, colors, etc.
            The shader will use these variables to process the pixels.

        5)  The active shader will process the pixels.
        6)  The shader is reset using love.graphics.setShader().
--]]
local shader_code = [[
    #pragma language glsl3

    // we don't want to calculate for every single light source
    // so we define a maximum number of lights
    // mostly used for performance reasons
    // if you have more lights, you can increase this value
    #define MAX_NUM_LIGHTS 16
    
    // (send from Lua)
    // Define a structure for the light sources

    struct DirectionalLight {
        vec4 color;                 // Color of the light source
        vec3 direction;             // Direction of the light source

        float ambientStrength;      // Ambient light strength
        float diffuseStrength;      // Diffuse light strength
        float specularStrength;     // Specular light strength
    };

    struct PointLight {
        vec2 position;              // Position of the light source in screen coordinates
        vec4 color;                 // Color of the light source  
        float constant;             // Constant value for light intensity calculation
        float linear;               // Linear value for light intensity calculation
        float quadratic;            // Quadratic value for light intensity calculation
        
        float ambientStrength;      // Ambient light strength
        float diffuseStrength;      // Diffuse light strength
        float specularStrength;     // Specular light strength
    };

    // SpotLight is a type of light that has a position, direction, and cutoff angles
    // It is used to create a cone of light that illuminates a specific area
    struct SpotLight {
        vec2 position;              // Position of the light source in screen coordinates
        vec4 color;                 // Color of the light source  
        float outerCutOff;          // Outer cutoff angle for the light cone (cosine of the angle)
        float innerCutOff;          // Inner cutoff angle for the light cone (cosine of the angle)
        vec2 direction;             // Direction of the light source

        // Constants for light attenuation
        float constant;             // Constant value for light intensity calculation
        float linear;               // Linear value for light intensity calculation
        float quadratic;            // Quadratic value for light intensity calculation
        
        // Constants for light strength
        float ambientStrength;      // Ambient light strength
        float diffuseStrength;      // Diffuse light strength
        float specularStrength;     // Specular light strength
    };

    extern SpotLight spotLights[MAX_NUM_LIGHTS];    // Array of light sources
    extern int num_lights;                      // Number of light sources (send from Lua)
    extern vec3 globalAmbientColor;             // Global ambient color for the scene

    vec4 effect(vec4 color, Image image, vec2 texture_coords, vec2 screen_coords) 
    {
        // Get the pixel color from the texture at the given texture coordinates
        vec4 pixel = Texel(image, texture_coords);

        // Initialize the pixel color with the global ambient color
        vec3 finalColor = globalAmbientColor;

        int current_num_lights = num_lights;
        if (current_num_lights > MAX_NUM_LIGHTS) {
            // If there are more lights than the maximum allowed, clamp the number of lights
            current_num_lights = MAX_NUM_LIGHTS;
        }
        
        // for each light source, calculate the light's effect on the pixel
        for (int i = 0; i < current_num_lights; i++) 
        {
            SpotLight light = spotLights[i];

            float theta = dot(
                normalize(screen_coords - light.position), // Vector from the light position to the pixel
                normalize(light.direction)                 // Direction of the light source 
            );
            float epsilon   = light.innerCutOff - light.outerCutOff;
            float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
        
            intensity *= light.diffuseStrength;
            intensity *= light.specularStrength;

            // Calculate the light's effect on the pixel color
            finalColor += light.color.rgb * intensity;
        }
        
        // Return the final color with alpha
        return pixel * vec4(finalColor, pixel.a); 
    }
]]


local love = require("love")
local GlobalConfig = require("global_config")
local shaders = {
    lightShader = shader_code,
}


return shaders