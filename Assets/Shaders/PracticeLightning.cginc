#ifndef PracticeLightning
#define PracticeLightning

float3 normalFromColor(float4 color) {
    #if defined(UNITY_NO_DXT5nm)
    return color.xyz;

    #else   
    // In this case, R channel is alpha
    float3 normal = float3(color.a, color.g, 0.0);
    normal.z = sqrt(1 - dot(normal, normal));
    
    return normal;
    #endif
}

float3 WorldNormalFromNormalMap(sampler2D normalMap, float2 normalTexCoord, float3 tangentWorld, float3 binormalWorld, float3 normalWorld) {
    // Color at Pixel which we read from Tangent space normal map
    float4 colorAtPixel = tex2D(normalMap, normalTexCoord);

    // Normal value converted from Color value
    float3 normalAtPixel = normalFromColor(colorAtPixel);

    // Compose TBN matrix 
    float3x3 TBNWorld = float3x3(tangentWorld, binormalWorld, normalWorld);

    return normalize(mul(normalAtPixel, TBNWorld));
}

#endif