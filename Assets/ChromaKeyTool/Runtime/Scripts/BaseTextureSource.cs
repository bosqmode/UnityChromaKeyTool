using UnityEngine;

namespace bosqmode.ChromaKeyTool
{
    /// <summary>
    /// Base class for all operations and texturesources
    /// </summary>
    public abstract class BaseTextureSource : MonoBehaviour
    {
        public abstract Texture Source { get; }
    }
}