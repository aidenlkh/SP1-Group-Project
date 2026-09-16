using UnityEngine;

public class JumpBoost : MonoBehaviour
{
    [SerializeField] private float jumpForce;
    [SerializeField] AudioClip jumpBoostFx;
    private Animator anim;
    private AudioSource audio;

    private void Start()
    {
        anim = GetComponent<Animator>();
        audio = GetComponent<AudioSource>();
    }
    
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            Rigidbody2D rgdbdy = collision.GetComponent<Rigidbody2D>();
            if(rgdbdy != null)
            {
                rgdbdy.linearVelocity = new Vector2(rgdbdy.linearVelocity.x, 0);
                rgdbdy.AddForce(new Vector2(0, jumpForce));
                anim.SetTrigger("Activate");
                audio.PlayOneShot(jumpBoostFx);
            }
        }
    }
}
