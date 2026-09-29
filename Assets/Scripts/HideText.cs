using UnityEngine;

public class HideText : MonoBehaviour
{
    public float time = 3f;

    void Start()
    {
        Invoke("Hide", time);
    }

    void Hide()
    {
        gameObject.SetActive(false);
    }
}
