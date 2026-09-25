using UnityEngine;
using UnityEngine.SceneManagement;

public class SpikeKillzone : MonoBehaviour
{
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.GetComponent<Health>().Kill();
            SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        }
    }
}
