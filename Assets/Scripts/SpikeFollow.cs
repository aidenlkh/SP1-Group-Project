using UnityEngine;

public class SpikeFollow : MonoBehaviour
{
    public float speed = 1f;
    public float startDelay = 5f;

    float timer;

    void Update()
    {
        timer += Time.deltaTime;

        if (timer >= startDelay)
            transform.position += Vector3.up * speed * Time.deltaTime;
    }
}
