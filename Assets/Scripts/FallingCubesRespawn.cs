using UnityEngine;

public class FallingCubesRespawn : MonoBehaviour
{
    public GameObject fallingCubePrefab;

    void Start()
    {
        InvokeRepeating("Spawn", 2f, 2f);
    }

    void Spawn()
    {
        float x = Camera.main.transform.position.x + Random.Range(-2f, 2f);
        float y = Camera.main.transform.position.y + 7f;
        Instantiate(fallingCubePrefab, new Vector3(x, y, 0f), Quaternion.identity);
    }
}