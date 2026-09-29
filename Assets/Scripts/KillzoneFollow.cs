using UnityEngine;

public class KillzoneFolliw : MonoBehaviour
{
    public Transform player;
    public float distanceBelow = 8f;

    float highestY;

    void Start()
    {
        ResetHeight();
    }

    void LateUpdate()
    {
        if (player == null) return;

        if (player.position.y > highestY)
            highestY = player.position.y;

        transform.position = new Vector3(transform.position.x, highestY - distanceBelow, transform.position.z);
    }

    public void ResetHeight()
    {
        if (player != null)
            highestY = player.position.y;
    }
}
