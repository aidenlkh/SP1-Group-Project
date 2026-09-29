using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Timer : MonoBehaviour
{
    public float timeLeft = 60f;
    public TMP_Text timerText;
    public GameObject winText;
    public GameObject dangers;
    public int sceneToLoad = 6;
    public float startDelay = 3f;

    private bool finished;
    private bool started;

    void Start()
    {
        Invoke("StartGame", startDelay);
    }

    void StartGame()
    {
        started = true;
        dangers.SetActive(true);
    }

    void Update()
    {
        if (finished || !started) return;

        timeLeft -= Time.deltaTime;
        timerText.text = Mathf.CeilToInt(timeLeft).ToString();

        if (timeLeft <= 0)
        {
            finished = true;
            timerText.text = "0";
            winText.SetActive(true);
            AudioListener.volume = 0f;
            dangers.SetActive(false);
            Invoke("LoadNextScene", 8f);
        }
    }

    void LoadNextScene()
    {
        AudioListener.volume = 1f;
        SceneManager.LoadScene(sceneToLoad);

    }
}