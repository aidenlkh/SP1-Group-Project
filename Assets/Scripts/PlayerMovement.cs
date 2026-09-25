using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField] private InputActionReference move;
    [SerializeField] private InputActionReference jump;
    [SerializeField] private float speed = 1f;
    [SerializeField] private float jumpHeight = 150f;
    [SerializeField] private Transform leftFoot, rightFoot, leftArm, rightArm;
    [SerializeField] private LayerMask ground;
    [SerializeField] AudioClip jumpFx;

    [SerializeField] private float dashLength;
    [SerializeField] private InputActionReference dash;
    [SerializeField] private float wallBounceX = 200f;
    [SerializeField] private float wallBounceY = 200f;
    [SerializeField] private LayerMask wall;
    [SerializeField] private float dashCooldown = 1f;
    [SerializeField] private float wallBounceCooldown = 1f;
    bool canDash = true;
    bool canWallBounce = true;
    bool hasDashed;
    bool wallOnLeft;
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
        jumpDust = GetComponentInChildren<ParticleSystem>();

        jump.action.started += Jump;
        dash.action.started += Dash;
    }


    void Update()
    {
        moveDirection = move.action.ReadValue<float>();
        anim.SetFloat("MS", Mathf.Abs(rgdbody.linearVelocity.x));
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
        if (!canMove)
        {
            return;
        }
        if (canWallBounce && CheckWall() == true && CheckGrounded() == false)
        {
            WallBounce();
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
        if (!hasDashed && canDash)
        {
            if (rendr.flipX == true)
            {
                rgdbody.AddForce(new Vector2(-dashLength, 0));
                hasDashed = true;
                anim.SetTrigger("Dash");
            }
            if (rendr.flipX == false)
            {
                rgdbody.AddForce(new Vector2(dashLength, 0));
                hasDashed = true;
                anim.SetTrigger("Dash");
            }
            canDash = false;
            Invoke("ResetDash", dashCooldown);
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
    private bool CheckWall()
    {
        RaycastHit2D lefthit = Physics2D.Raycast(leftArm.position, Vector2.left, rayCastDistance, wall);
        RaycastHit2D righthit = Physics2D.Raycast(rightArm.position, Vector2.right, rayCastDistance, wall);

        if (lefthit.collider != null && lefthit || righthit.collider != null && righthit)
        {
            wallOnLeft = lefthit.collider != null;
            return true;
        }
        else
        {
            return false;
        }
    }
    private void WallBounce()
    {
        float direction;
        if (wallOnLeft)
        {
            direction = 1f;
        }
        else
        {
            direction = -1f;
        }

        rgdbody.linearVelocity = Vector2.zero;
        FlipSprite(direction < 0f);
        TakeKnockBack(direction * wallBounceX, wallBounceY);
        anim.SetTrigger("WalBounce");
        canWallBounce = false;
        Invoke("ResetWallBounce", wallBounceCooldown);
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
    private void ResetDash()
    {
        canDash = true;
    }

    private void ResetWallBounce()
    {
        canWallBounce = true;
    }
}