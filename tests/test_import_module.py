# Utility imports
import unittest

# Test imports
import h5py
import pandas as pd
import numpy as np
import scipy 
import matplotlib.pyplot as plt
import mpi4py
import jax.numpy as jnp
import radia as rad


class RadiaSmokeTest(unittest.TestCase):
    """
    Tests the Radia is available and gives sensible results.
    """

    def test_radia_version_string(self):
        
        self.assertEqual(type(rad.UtiVer()), float)

    def test_radia_simple_magnet(self):
        
        rad.UtiDelAll()
        magnet   = rad.ObjRecMag([0,0,0], [1,1,1], [0,1,0])
        observed = np.array(rad.Fld(magnet, 'b', [1,2,3]), dtype=np.float32)

        expected = np.array([0.0006504201540729257, -0.00021819974895862903, 0.0019537852236147252], dtype=np.float32)

        self.assertTrue(np.allclose(observed, expected))
