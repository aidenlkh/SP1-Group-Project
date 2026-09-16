using Unity.VisualScripting;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    [SerializeField] private Transform target1, target2;
    [SerializeField] private float moveSpeed;
    private Transform currentTarget;

    private void Start()
    {
        currentTarget = target1;
    }

    private void FixedUpdate()
    
    {
        if(transform.position == target1.position)
        {
            currentTarget = target2;
        }
        if (transform.position == target2.position)
        {
            currentTarget = target1;
        }
        transform.position = Vector2.MoveTowards(transform.position, currentTarget.position, moveSpeed * Time.deltaTime);
    }
    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Player") && collision.transform.position.y > transform.position.y)
        {
            collision.transform.SetParent(transform);
        }    
    }
    private void OnCollisionExit2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.transform.SetParent(null);
        }
    }



}
