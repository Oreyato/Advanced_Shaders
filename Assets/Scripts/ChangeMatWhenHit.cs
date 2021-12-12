using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeMatWhenHit : MonoBehaviour
{
    Shader outlineShader;

    // Start is called before the first frame update
    void Start()
    {
        outlineShader = Shader.Find("Custom/Outline");
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0)) {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            Debug.Log("button clicked");

            if (Physics.Raycast(ray, out hit, 100.0f)) {
                hit.collider.gameObject.GetComponent<RotativeObject>().rotation.x = 0.2f;

                Transform parent = hit.collider.gameObject.transform.parent;

                Debug.Log(parent.childCount);

                Debug.Log("raycast hit");

                for (int i = 0; i < parent.childCount; i++)
                {
                    GameObject childObj = parent.GetChild(i).gameObject;
                    childObj.GetComponent<RotativeObject>().rotation.x = 0; // Error: Object reference not set to an instance of an object
                    childObj.GetComponent<Renderer>().sharedMaterial.shader = Shader.Find("Standard");
                }

                GameObject gameObj = hit.collider.gameObject;
                Material mat = gameObj.GetComponent<Renderer>().material;

                gameObj.GetComponent<RotativeObject>().rotation.x = 2.2f;
                mat.shader = outlineShader;
                mat.SetFloat("_Outline", 0.1f);
            }
        }
    }
}
