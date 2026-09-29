using UnityEngine;

public class SawTouch : MonoBehaviour
{
    private void OnTriggerEnter2D(Collider2D collusion)
    {
        if (collusion.CompareTag("Player"))
        {
            collusion.GetComponent<Health>().TakeDamage(1);
            collusion.GetComponent<Flash>().FlashPlayer();
            float direction = collusion.transform.position.x > transform.position.x ? 1f : -1f;
            collusion.GetComponent<PlayerMovement>().TakeKnockBack(direction * 200f, 100f);
        }
    }
}
