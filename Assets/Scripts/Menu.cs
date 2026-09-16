using UnityEngine;
using UnityEngine.SceneManagement;


public class NewMonoBehaviourScript : MonoBehaviour
    
{
    [SerializeField] GameObject creditsPanel;
    [SerializeField] private int lvlindex;
    public void StartGame()
    {
        SceneManager.LoadScene(lvlindex);
    }

    public void QuitGame()
    {
        Application.Quit();
    }

    public void Credits()
    {
        creditsPanel.SetActive(true);
    }

    public void HideCredits()
    {
        creditsPanel.SetActive(false);
    }

}



