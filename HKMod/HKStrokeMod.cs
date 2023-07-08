using HKTool;
using HKTool.Utils;
using Modding;
using Modding.Utils;
using System;
using System.Collections.Generic;
using UnityEngine;

namespace HKStroke
{
    public class HKStrokeMod : ModBase<HKStrokeMod>, ITogglableMod
    {
        public static AssetBundle ab = AssetBundle.LoadFromMemory(ModResources.SHADERS);
        public static bool isEnabled = false;
        public HKStrokeMod()
        {
            CameraPostProcesser.material = ab.LoadAsset<Material>("Assets/Shaders/StrokeMat.mat");
        }
        public override void Initialize()
        { 
            LogError("Enable HKStroke!!!!!!!!!!!!!!!!!!!!!");
            isEnabled = true;

            if(GameManager._instance != null && !GameManager._instance.IsMenuScene())
            {
                GameCameras.instance.hudCamera.gameObject.GetOrAddComponent<CameraPostProcesser>();
            }
            On.HeroController.Awake += HeroController_Awake;
            UnityEngine.SceneManagement.SceneManager.sceneLoaded += SceneManager_sceneLoaded;
        }
        private readonly static List<string> blacklist = new()
        {
            "haze",
            "black_fader_GG"
        };
        private void SceneManager_sceneLoaded(UnityEngine.SceneManagement.Scene arg0, 
            UnityEngine.SceneManagement.LoadSceneMode arg1)
        {
            foreach(var sr in GameObject.FindObjectsOfType<SpriteRenderer>())
            {
                var n = sr.name;
                foreach(var b in blacklist)
                {
                    if(n.IndexOf(b, StringComparison.OrdinalIgnoreCase) != -1)
                    {
                        sr.gameObject.SetActive(false);
                        sr.gameObject.SetActiveChildren(false);
                    }
                }
            }
        }

        private void DisableSR(GameObject root, string go)
        {
            var g = root.FindChild(go);
            if (g == null) return;
            //g.SetActive(false);
            //g.transform.localScale = new(0, 0, 0);
            foreach(var r in g.GetComponents<Renderer>())
            {
                r.enabled = false;
            }
        }
        private void HeroController_Awake(On.HeroController.orig_Awake orig, HeroController self)
        {
            LogError("Attach camera !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            orig(self);

            GameCameras.instance.hudCamera.gameObject.GetOrAddComponent<CameraPostProcesser>();

            IEnumerator<object> Wait()
            {
                yield return new WaitForSeconds(0.12f);
                DisableSR(self.gameObject, "HeroLight");
                DisableSR(self.gameObject, "Vignette");
                DisableSR(self.gameObject, "white_light_donut");
            }

            Wait().StartCoroutine();

            
        }

        public void Unload()
        {
            LogError("Disable HKStroke!!!!!!!!!!!!!!!!!!!!!");
            isEnabled = false;
            On.HeroController.Awake -= HeroController_Awake;

            foreach (var v in CameraPostProcesser.FindObjectsOfType<CameraPostProcesser>())
            {
                CameraPostProcesser.DestroyImmediate(v);
            }
        }
    }
}
