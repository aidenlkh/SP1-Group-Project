using UnityEngine;

public class FallingCube : MonoBehaviour
{
    void Start()
    {
        Destroy(gameObject, 5f);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<Health>().TakeDamage(1);
            other.GetComponent<Flash>().FlashPlayer();
            Destroy(gameObject);
        }
    }
}
