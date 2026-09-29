using UnityEngine;

public class IceFalling : MonoBehaviour

{
    public GameObject fallingIceprefab;
    void Start()
    {
        InvokeRepeating("Spawn", 1f, 1f);
    }

    void Spawn()
    {
        float x = Camera.main.transform.position.x + Random.Range(-10f, 10f);
        float y = Camera.main.transform.position.y + 7f;
        Instantiate(fallingIceprefab, new Vector3(x, y, 0f), Quaternion.identity);
    }
}

