using UnityEngine;
using UnityEngine.UI;

namespace bosqmode.ChromaKeyTool
{
    /// <summary>
    /// Operation class
    /// </summary>
    public class BlitOperation : BaseTextureSource
    {
        public override Texture Source => m_target;

        [Tooltip("Source from which to get a texture from")]
        [SerializeField]
        private BaseTextureSource m_source;

        [Tooltip("Operation for this pass")]
        [SerializeField]
        public OperationType Operation;

        private OperationType m_operation;

        [Tooltip("RawImage to render the result to (CAN BE LEFT EMPTY)")]
        [SerializeField]
        private RawImage m_targetRawImage;

        [Tooltip("When on, the target texture will be cleared on every update. Most likely this should be left on")]
        [SerializeField]
        private bool m_clearTextureOnUpdate = true;

        private RenderTexture m_target;

        private Material m_mat;

        [HideInInspector]
        public Color LightColor = new Color(0, 250f/255f, 0);
        private Color m_lightColor;
        [HideInInspector]
        public Color DarkColor = new Color(48f/255f, 156f/255f, 67f/255f);
        private Color m_darkColor;
        [HideInInspector]
        public float Threshhold = 0.3f;
        private float m_threshhold;

        [HideInInspector]
        public ErodeAmount ErodeAmount = ErodeAmount._1X;
        private ErodeAmount m_erodeAmount = ErodeAmount._1X;

        [HideInInspector]
        public float BlurSize = 0.01f;
        private float m_blurSize = 0.01f;

        /// <summary>
        /// Updates the operation shader
        /// </summary>
        private void UpdateOperation()
        {
            m_operation = Operation;

            Material opmat;

            switch (m_operation)
            {
                case OperationType.CHROMA_KEY:
                    opmat = Resources.Load<Material>("ChromaKeyOp");
                    break;
                case OperationType.ERODE_ALPHA:
                    opmat = Resources.Load<Material>("ErodeOp");
                    break;
                case OperationType.BLUR_ALPHA:
                    opmat = Resources.Load<Material>("BlurOp");
                    break;
                case OperationType.DESPILL:
                    opmat = Resources.Load<Material>("DespillOp");
                    break;
                default:
                    opmat = Resources.Load<Material>("ChromaKeyOp");
                    break;
            }

            m_mat = new Material(opmat);
        }

        /// <summary>
        /// Creates the target texture
        /// </summary>
        private void CreateTarget()
        {
            if (m_source.Source == null)
            {
                return;
            }

            m_target = new RenderTexture(m_source.Source.width, m_source.Source.height, 0);
            m_target.autoGenerateMips = false;

            if (m_targetRawImage)
            {
                m_targetRawImage.texture = m_target;
            }
        }

        private bool SettingUpdate()
        {
            switch (Operation)
            {
                case OperationType.CHROMA_KEY:
                    if(m_darkColor != DarkColor || m_lightColor != LightColor || m_threshhold != Threshhold)
                    {
                        m_darkColor = DarkColor;
                        m_lightColor = LightColor;
                        m_threshhold = Threshhold;
                        m_mat.SetColor("_LightColor", m_lightColor);
                        m_mat.SetColor("_DarkColor", m_darkColor);
                        m_mat.SetFloat("_Threshhold", m_threshhold);
                        return true;
                    }
                    break;
                case OperationType.ERODE_ALPHA:
                    if(m_erodeAmount != ErodeAmount)
                    {
                        m_mat.DisableKeyword(m_erodeAmount.ToString());
                        m_erodeAmount = ErodeAmount;
                        m_mat.EnableKeyword(m_erodeAmount.ToString());
                        return true;
                    }
                    break;
                case OperationType.BLUR_ALPHA:
                    if(m_blurSize != BlurSize)
                    {
                        m_blurSize = BlurSize;
                        m_mat.SetFloat("_BlurSize", m_blurSize);
                        return true;
                    }
                    break;
            }

            return false;
        }

        private void Update()
        {
            if (m_mat == null || m_operation != Operation)
            {
                UpdateOperation();
            }

            SettingUpdate();

            // Create target if it is yet to be initialized or the source texture's dimension has changed
            if (m_target == null || (m_target.width != m_source.Source.width || m_target.height != m_source.Source.height))
            {
                CreateTarget();
                return;
            }

            if (m_clearTextureOnUpdate)
            {
                ClearTargetTexture(m_target);
            }

            Graphics.Blit(m_source.Source, m_target, m_mat);
        }

        private void ClearTargetTexture(RenderTexture rt)
        {
            RenderTexture rend = RenderTexture.active;
            RenderTexture.active = rt;
            GL.Clear(true, true, Color.clear);
            RenderTexture.active = rend;
        }
    }

    public enum OperationType
    {
        CHROMA_KEY,
        ERODE_ALPHA,
        BLUR_ALPHA,
        DESPILL
    }

    public enum ErodeAmount
    {
        _1X,
        _2X,
        _3X,
        _5X,
        _9X
    }
}