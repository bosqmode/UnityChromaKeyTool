using UnityEngine;

namespace bosqmode.ChromaKeyTool
{
    public class TextureSource : BaseTextureSource
    {
        [SerializeField]
        private Texture m_source;

        public override Texture Source => m_source;
    }

}