using UnityEditor;
using System.IO;
using System.Collections.Generic;

public class CreateAssetbundles
{

    [MenuItem("AssetsBundle/Build AssetBundles")]
    static void BuildAllAssetBundles()
    {
        string dir = "./HKMod/AssetBundle";

        var platform = new List<BuildTarget>()
        {
            BuildTarget.StandaloneOSX,
            BuildTarget.StandaloneWindows,
            BuildTarget.StandaloneLinux64
        };
        foreach(var v in platform)
        {
            var d = Path.Combine(dir, v.ToString());
            Directory.CreateDirectory(d);
            BuildPipeline.BuildAssetBundles(d, BuildAssetBundleOptions.ChunkBasedCompression, v);
        }
        

        
    }
}
