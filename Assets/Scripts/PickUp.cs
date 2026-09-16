using UnityEngine;

public class PickUp : MonoBehaviour
{
    [SerializeField] GameObject ballParticle;
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.gameObject.GetComponent<PlayerQuest>().AddBalls();
            Instantiate(ballParticle, transform.position, Quaternion.identity);
        }
        Destroy(gameObject);
    }
}
