using UnityEngine;

public class CleanUp : MonoBehaviour
{
    [SerializeField] private float cleanUpTimer;
    void Start()
    {
        Destroy(gameObject, cleanUpTimer);
    }


}
