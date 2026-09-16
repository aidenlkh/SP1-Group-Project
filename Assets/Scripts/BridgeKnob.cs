using UnityEngine;

public class BridgeKnob : MonoBehaviour
{
    [SerializeField] private GameObject knob;
    [SerializeField] AudioClip bridge;
    private Animator anim;
    private AudioSource audio;
    void Start()
    {
        anim = GetComponent<Animator>();
        audio = GetComponent<AudioSource>();
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            anim.SetTrigger("Move");
            audio.PlayOneShot(bridge);
            knob.SetActive(false);
        }
    }
}
