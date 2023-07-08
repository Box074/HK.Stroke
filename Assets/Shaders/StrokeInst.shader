Shader "Stroke/StrokeInst"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        [MainColor] _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[9] : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;  
            uniform half4 _MainTex_TexelSize;
            fixed4 _Color;
            #define _EdgeOnly 1.4
            #define _EdgeColor fixed4(0,0,0,1)
            #define _BackgroundColor fixed4(1,1,1,1)

            fixed luminance(fixed4 color) {
            	return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
            }
            			
            half Sobel(v2f i) {
            	const half Gx[9] = {-1,  0,  1,
            			    -2,  0,  2,
            			    -1,  0,  1};
            	const half Gy[9] = {-1, -2, -1,
            			     0,  0,  0,
            			     1,  2,  1};		
            				
            	half texColor;
            	half edgeX = 0;
            	half edgeY = 0;
            	for (int it = 0; it < 9; it++) {
            	        texColor = luminance(tex2D(_MainTex, i.uv[it]) * _Color);
            		edgeX += texColor * Gx[it];
            		edgeY += texColor * Gy[it];
            	}
            				
            	half edge = 1 - abs(edgeX) - abs(edgeY);
            				
            	return edge;
            }
            
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                half2 uv = v.uv;
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
	            o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
	            o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
	            o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
	            o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
	            o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
	            o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
	            o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
	            o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                return o;
            }

            

            float4 frag (v2f i) : SV_Target
            {
                half edge = Sobel(i);

                fixed4 col = tex2D(_MainTex, i.uv[4]) * _Color;
				
	            fixed4 withEdgeColor = lerp(_EdgeColor, col, edge);
	            fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
	            fixed4 ret = lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
                
                if(col.a < 0.8) {
                    if(abs(col.r - col.b) < 0.1 && abs(col.r - col.g) < 0.1) {
                        discard;
                    }
                }
                if(col.a < 0.3) {
                    discard;
                }

                ret.a = col.a;
                return ret;
            }
            ENDCG
        }
    
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed4 _Color;
            #define _lineWidth 1

            float4 frag(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv) * _Color;
                float2 up_uv = i.uv + float2(0,1) * _lineWidth * _MainTex_TexelSize.xy;
                float2 down_uv = i.uv + float2(0,-1) * _lineWidth * _MainTex_TexelSize.xy;
                float2 left_uv = i.uv + float2(-1,0) * _lineWidth * _MainTex_TexelSize.xy;
                float2 right_uv = i.uv + float2(1,0) * _lineWidth * _MainTex_TexelSize.xy;

                float w = tex2D(_MainTex,up_uv).a * tex2D(_MainTex,down_uv).a * tex2D(_MainTex,left_uv).a * tex2D(_MainTex,right_uv).a;
                if(w > 0.3) {
                    discard;
                }
                if(col.a <= 0.5) {
                    discard;
                }
                return lerp(float4(0,0,0,col.a), float4(1,1,1,col.a), w);
            }

            ENDCG
        }
    }
}
