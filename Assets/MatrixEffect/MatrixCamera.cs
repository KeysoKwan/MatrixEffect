using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatrixCamera : MonoBehaviour
{
    [SerializeField]
    Shader matrixVfx;
    void Start()
    {
        Camera.main.SetReplacementShader(matrixVfx, "");
    }
}
