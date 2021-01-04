//C# Example (LookAtPointEditor.cs)
using UnityEngine;
using UnityEditor;

#if UNITY_EDITOR

namespace bosqmode.ChromaKeyTool
{
    [CustomEditor(typeof(BlitOperation))]
    [CanEditMultipleObjects]
    public class BlitOperationEditor : Editor
    {
        SerializedProperty operation, lcolor, dcolor, threshhold, erode, blursize;

        void OnEnable()
        {
            operation = serializedObject.FindProperty("Operation");
            lcolor = serializedObject.FindProperty("LightColor");
            dcolor = serializedObject.FindProperty("DarkColor");
            threshhold = serializedObject.FindProperty("Threshhold");
            erode = serializedObject.FindProperty("ErodeAmount");
            blursize = serializedObject.FindProperty("BlurSize");
        }

        private void DrawChromaInspector()
        {
            EditorGUILayout.PropertyField(lcolor);
            EditorGUILayout.PropertyField(dcolor);
            EditorGUILayout.Slider(threshhold, 0, 1);
        }

        private void DrawErodeInspector()
        {
            EditorGUILayout.PropertyField(erode);
        }

        private void DrawBlurInspector()
        {
            EditorGUILayout.Slider(blursize, 0, 0.5f);
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            DrawDefaultInspector();

            switch ((OperationType)operation.enumValueIndex)
            {
                case OperationType.CHROMA_KEY:
                    DrawChromaInspector();
                    break;
                case OperationType.ERODE_ALPHA:
                    DrawErodeInspector();
                    break;
                case OperationType.BLUR_ALPHA:
                    DrawBlurInspector();
                    break;
                case OperationType.DESPILL:
                    break;
                default:
                    DrawChromaInspector();
                    break;
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}

#endif