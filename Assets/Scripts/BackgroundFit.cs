using UnityEngine;
[ExecuteAlways]

public class BackgroundFit : MonoBehaviour
{
    private SpriteRenderer sr;

    void LateUpdate()
    {
        Camera cam = Camera.main;
        if (cam == null) return;
        if (sr == null) sr = GetComponent<SpriteRenderer>();

        float height = cam.orthographicSize * 2f;
        float width = height * cam.aspect;
        transform.localScale = new Vector3(width, height, 1f);

        if (sr.sharedMaterial != null && sr.sharedMaterial.HasProperty("_Aspect"))
        {
            sr.sharedMaterial.SetFloat("_Aspect", width / height);
        }
    }
}
