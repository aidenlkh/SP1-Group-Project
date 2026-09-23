
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField] private InputActionReference move;
    [SerializeField] private InputActionReference jump;
    [SerializeField] private float speed = 1f;
    [SerializeField] private float jumpHeight = 150f;
    [SerializeField] private Transform leftFoot, rightFoot;
    [SerializeField] private LayerMask ground;
    [SerializeField] AudioClip jumpFx;

    [SerializeField] private float dashLength;
    [SerializeField] private InputActionReference dash;
    bool hasDashed;
    bool canMove = true;

    
    private bool grounded; 

    private float moveDirection;
    private ParticleSystem jumpDust; 

    private Rigidbody2D rgdbody;
    private SpriteRenderer rendr;
    private Animator anim;
    private AudioSource audio;
    [SerializeField] private float rayCastDistance = 0.25f; 
   
    void Start()
    {
        rgdbody = GetComponent<Rigidbody2D>();
        rendr = GetComponent<SpriteRenderer>();
        anim = GetComponent<Animator>();
        audio = GetComponent<AudioSource>();
        jumpDust = GetComponentInChildren <ParticleSystem>();

        jump.action.started += Jump;
        dash.action.started += Dash;
    }

   
    void Update()
    {
        moveDirection = move.action.ReadValue<float>();
        anim.SetFloat("MS",Mathf.Abs(rgdbody.linearVelocity.x));
        anim.SetFloat("VertS", rgdbody.linearVelocity.y);
        anim.SetBool("Grounded", CheckGrounded());

        if (moveDirection < 0f)

        {
            FlipSprite(true);
        }
        if (moveDirection > 0f)
        {
            FlipSprite(false);
        }
    }

    private void FixedUpdate()

    {
        if(!canMove) 
        {
            return;
        }
        rgdbody.linearVelocity = new Vector2(moveDirection * speed * Time.deltaTime, rgdbody.linearVelocity.y);
    }

    private void FlipSprite(bool direction)
    {
        rendr.flipX = direction;
    }

    private void Jump(InputAction.CallbackContext context)
    {
        if (CheckGrounded() == true)
        { 
         rgdbody.AddForce(new Vector2(0, jumpHeight));
            jumpDust.Play();
            audio.PlayOneShot(jumpFx);
        }
    }

    private void Dash(InputAction.CallbackContext context)
    {
        if (!hasDashed)
        {
            if (rendr.flipX == true)

            {
                rgdbody.AddForce(new Vector2(-dashLength, 0));
                hasDashed = true;
            }
            if (rendr.flipX == false)
            {
                rgdbody.AddForce(new Vector2(dashLength, 0));
                hasDashed = true;

            }


        }

    }


    private bool CheckGrounded()

    {
        RaycastHit2D lefthit = Physics2D.Raycast(leftFoot.position, Vector2.down, rayCastDistance, ground);
        RaycastHit2D righthit = Physics2D.Raycast(rightFoot.position, Vector2.down, rayCastDistance, ground);
       

        if (lefthit.collider != null && lefthit || righthit.collider != null && righthit)
        {
            hasDashed = false;
            return true;
        }
        else
        {
            return false;
        }
        
    }
    public void TakeKnockBack(float knockBackF, float upwardsF)
    {
        canMove = false;
        rgdbody.AddForce(new Vector2(knockBackF, upwardsF));
        Invoke("CanMoveAgain", 0.25f);
    }
    private void CanMoveAgain()
    {
        canMove = true;
    }
}
