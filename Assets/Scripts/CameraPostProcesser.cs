#if HKMOD
using Modding.Utils;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using UnityEngine;

public class CameraPostProcesser : MonoBehaviour
{
    private Camera current;
    private Camera renderCamera;
#if HKMOD
    public static Material material;
#else
    public Material material;
#endif


    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
#if HKMOD
        if (GameManager._instance == null || GameManager._instance.IsMenuScene())
        {
            Graphics.Blit(src, dst);
            return;
        }
#endif
        Graphics.Blit(Texture2D.blackTexture, dst);
        Graphics.Blit(src, dst, material);
    }

}
