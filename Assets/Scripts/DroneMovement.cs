using UnityEngine;

public class DroneMovement : MonoBehaviour
{
    [SerializeField] private float mS = 2.0f;
    [SerializeField] private float bounce = 250f;
    [SerializeField] private int damageGiven = 1;

    [SerializeField] private float knockBackF = 100;
    [SerializeField] private float upwardsF = 5;
    [SerializeField] AudioClip explosion;
    [SerializeField] private GameObject explo;

    private SpriteRenderer rendr;

    private void Awake ()
    {
        rendr = GetComponent<SpriteRenderer>();
    }

    private void Update()
    {
        if (mS < 0)
        {
            rendr.flipX = true;       
        }
        if (mS > 0) 
        {
            rendr.flipX = false;
        }
    }
    void FixedUpdate()
    {
        transform.Translate(new Vector2(mS, 0) * Time.deltaTime);
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if(collision.gameObject.CompareTag("DroneBlock") || collision.gameObject.CompareTag("Drone"))
        {
            mS = -mS;
        }
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.gameObject.GetComponent<Health>().TakeDamage(damageGiven);
            if (collision.transform.position.x > transform.position.x)
            {
                collision.gameObject.GetComponent<PlayerMovement>().TakeKnockBack(knockBackF, upwardsF);
            }
            else
            {
                collision.gameObject.GetComponent<PlayerMovement>().TakeKnockBack(-knockBackF, upwardsF);
            }
        }
    }
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {

            Rigidbody2D rgdbody = collision.attachedRigidbody;

            if(rgdbody != null)
            {
                rgdbody.linearVelocity = new Vector2(rgdbody.linearVelocity.x, 0);
                rgdbody.AddForce(new Vector2(0, bounce));
            }
            AudioSource.PlayClipAtPoint(explosion, transform.position, 30f);
            Instantiate(explo, transform.position, Quaternion.identity);
            Destroy(gameObject);
            
        }
    }

}


