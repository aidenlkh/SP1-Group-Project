using System;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.UI;

public class Health : MonoBehaviour
{

    [SerializeField] private int startingHealth = 5;
    [SerializeField] Transform spawnPos;
    [SerializeField] Slider hpSlider;
    private int currentHealth;
    [SerializeField] Image fillImage;

    void Start()
    {
        currentHealth = startingHealth;
        UpdateHpBar();
    }
    public void TakeDamage(int dmg)
    {
        currentHealth -= 1;
        UpdateHpBar();

        if (currentHealth <= 0)
        {
            Respawn();
        }
    }
    private void Respawn()
    {
        currentHealth = startingHealth;
        UpdateHpBar();
        transform.position = spawnPos.position;
        GetComponent<Rigidbody2D>().linearVelocity = Vector2.zero;
    }    
    private void UpdateHpBar() 
    {
        hpSlider.value = currentHealth;

        if(currentHealth  <= 2) 
        {
            fillImage.color = Color.red;
        }
        else if (currentHealth <= 3)
        {
            fillImage.color = Color.orange;
        }
        else
        {
            fillImage.color = Color.darkSeaGreen;
        }

    }
    public bool AddHealth(int hpToAdd)
    {
        if (currentHealth >= startingHealth)
        {
            return false;
        }
        currentHealth += hpToAdd;
        UpdateHpBar();

        if (currentHealth>startingHealth)
        {
            currentHealth = startingHealth;
        }
       
        return true;
    }

  
}
