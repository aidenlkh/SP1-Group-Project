using UnityEngine;
using TMPro;

public class PlayerQuest : MonoBehaviour
    
{
    [SerializeField] private int ballsToCollect = 20;
    [SerializeField] private TMP_Text ballText;
    [SerializeField] AudioClip pickUpFx;
    private int balls = 0;
    private AudioSource audio;

    private void Start()
    {
        ballText.text = "" + balls;
        audio = GetComponent<AudioSource>();
    }
    
    




    public void AddBalls()
    {
        balls++;
        ballText.text = "" + balls;
        audio.pitch = Random.Range(0.1f, 1.5f);
        audio.PlayOneShot(pickUpFx);
    }

    public int GetBalls() {return balls;}
    public int GetBallsToCollect() {return ballsToCollect;}
}
