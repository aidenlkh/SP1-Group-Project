using UnityEngine;

public class Parallax : MonoBehaviour
{
    [SerializeField] private float parallaxAmount = 0.2f;

    private Transform cam;
    private float lastCameraX;

    private void Start()
    {
        cam = Camera.main.transform;
        lastCameraX = cam.position.x;
    }

    private void LateUpdate()
    {
        float cameraMovement = cam.position.x - lastCameraX;

        transform.position += Vector3.right * cameraMovement * parallaxAmount;

        lastCameraX = cam.position.x;
    }
}