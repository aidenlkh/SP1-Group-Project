using UnityEngine;
using UnityEngine.SceneManagement;


public class QuestCheck : MonoBehaviour
{
    [SerializeField] private GameObject doneText, notdoneText, byeText;
    [SerializeField] private float byeTextDelay = 4f;
    [SerializeField] AudioClip deckFx;
    [SerializeField] AudioClip deckFx2;
    [SerializeField] private int lvlindenx;
    private AudioSource audio; 
    private void Awake()
    {
        audio = GetComponent<AudioSource>();
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            if (collision.GetComponent<PlayerQuest>().GetBalls() >= collision.GetComponent<PlayerQuest>().GetBallsToCollect())
            {
                doneText.SetActive(true);
                GetComponent<Animator>().enabled = true;
                Invoke("ShowByeText", byeTextDelay);
                audio.PlayOneShot(deckFx2);
                Invoke("LoadNextLevel", 5f);
            }
            else
            {
                notdoneText.SetActive(true);
                audio.PlayOneShot(deckFx);
            }
        }
    }

    private void ShowByeText()
    {
        byeText.SetActive(true);
    }

    private void LoadNextLevel()
{
        SceneManager.LoadScene(lvlindenx);
}
    private void OnTriggerExit2D(Collider2D collision)
    {
        doneText.SetActive(false);
        notdoneText.SetActive(false);
    }
}