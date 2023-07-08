Shader "Stroke/Stroke"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
         [MainColor] _Color ("Color", Color) = (1,1,1,1)
	    _EdgeOnly ("Edge Only", Float) = 1.0
	    _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
	    _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
        _lineWidth ("Line Width", Float) = 1.0
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

            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

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
                
                if(col.a == 0) {
                    discard;
                }
                ret.a = col.a;
                ret.rgb = 1- ret.rgb;
                return ret;
            }
            ENDCG

        }
    }
}
