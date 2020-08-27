using UnityEngine;
using UnityEngine.UI;

namespace bosqmode.ChromaKeyTool
{
    /// <summary>
    /// Provides a RawImage's texture as Source
    /// </summary>
    public class RawImageSource : BaseTextureSource
    {
        [Tooltip("RawImage of which's texture will be used as a Source")]
        [SerializeField]
        private RawImage m_rawImage;

        public override Texture Source => m_rawImage.texture;
    }
}