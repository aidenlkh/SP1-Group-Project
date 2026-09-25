using UnityEngine;

public class Flash : MonoBehaviour
{
    SpriteRenderer sr;

    void Start()
    {
        sr = GetComponent<SpriteRenderer>();
    }

    public void FlashPlayer()
    {
        sr.color = Color.red;
        Invoke("ResetColor", 0.5f);
    }

    void ResetColor()
    {
        sr.color = Color.white;
    }
}
