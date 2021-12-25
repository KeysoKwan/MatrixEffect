using System.Runtime.CompilerServices;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatrixCamera : MonoBehaviour
{
    private bool _inMatrix = false;

    public bool InMatrix
    {
        get
        {
            return _inMatrix;
        }
    }

    [SerializeField]
    Material _matrixMaterial;

    [SerializeField]
    Material _matrixSkyMaterial;

    Dictionary<Renderer, Material[]> _meshDic;

    Dictionary<Renderer, Material[]> meshDic
    {
        get
        {
            if (_meshDic == null)
            {
                _meshDic = new Dictionary<Renderer, Material[]>();
                Renderer[] meshes = FindObjectsOfType<Renderer>();
                foreach (var mesh in meshes)
                {
                    _meshDic.Add(mesh, mesh.materials);
                }
                _skyBoxMat = RenderSettings.skybox;
            }
            return _meshDic;
        }
    }

    private Material _skyBoxMat;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F1))
        {
            MatrixEffect();
        }
    }

    public void MatrixEffect()
    {
        _inMatrix = !_inMatrix;

        if (_inMatrix) EnterMatrix();
        else ExitMatrix();
    }

    public void MatrixEffect(bool isEnter)
    {
        if (isEnter) EnterMatrix();
        else ExitMatrix();
    }

    void EnterMatrix()
    {
        foreach (var item in meshDic)
        {
            Material[] materials = item.Key.materials;
            for (int i = 0; i < materials.Length; i++)
            {
                materials[i] = _matrixMaterial;
            }
            item.Key.materials = materials;
        }
        RenderSettings.skybox = _matrixSkyMaterial;
        _inMatrix = true;
    }

    void ExitMatrix()
    {
        foreach (var item in meshDic)
        {
            Material[] materials = item.Value;
            item.Key.materials = materials;
        }
        RenderSettings.skybox = _skyBoxMat;
        _inMatrix = false;
    }
}
