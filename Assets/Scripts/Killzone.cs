using Unity.VisualScripting;
using UnityEngine;

public class Killzone : MonoBehaviour
{
    [SerializeField] private Transform spawnPos; 
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player")) 
        {
            collision.transform.position = spawnPos.position;
            collision.GetComponent<Health>().TakeDamage(1);
            collision.GetComponent<Rigidbody2D>().linearVelocity = Vector2.zero;

        }
    }
}
