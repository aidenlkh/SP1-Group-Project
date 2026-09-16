using Unity.VisualScripting;
using UnityEngine;

public class Came : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private Vector3 offSet = new Vector3(0, 0, -10);
    [SerializeField] private float smoothing; 
   
    private void LateUpdate()
    {
        Vector3 newPostition = Vector3.Lerp(transform.position, target.position + offSet, smoothing * Time.deltaTime);
        transform.position = newPostition;
    }
    
}
