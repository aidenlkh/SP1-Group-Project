using UnityEngine;

public class Computer : MonoBehaviour
{
    [SerializeField] private GameObject popUp;
    [SerializeField] AudioClip holoFx;
    private AudioSource audio;

    private void Awake()
    {
        audio = GetComponent<AudioSource>();
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            popUp.SetActive(true);
            audio.PlayOneShot(holoFx);
        }
    }
    private void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            popUp.SetActive(false);
        }
    }

}
