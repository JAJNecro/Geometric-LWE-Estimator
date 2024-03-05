

# This file was *autogenerated* from the file ring_ebdd.sage
from sage.all_cmdline import *   # import sage library

_sage_const_25 = Integer(25); _sage_const_64 = Integer(64); _sage_const_3329 = Integer(3329); _sage_const_20 = Integer(20); _sage_const_0 = Integer(0); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_12 = Integer(12); _sage_const_50 = Integer(50)
load('../framework/LWE.sage')
load('../framework/utils.sage')
import pandas as pd
import time

predicted_betas = []
calculated_betas = []
norms = []
solutions = []
times = []

num_experiments = _sage_const_25 
for x in range(num_experiments):
    start = time.time()
    print("========================================== Experiment: " + str(x) + "=========================================")
    n = _sage_const_64 
    m = n
    q = _sage_const_3329 
    sigma = sqrt(_sage_const_20 )
    sigma_c = []
    mu = concatenate([_sage_const_0 ] * (m+n), [])
    d = m + n

    #Setting up Sigma
    for i in range(_sage_const_0 , n):
        sigma_c.append(((sigma / q) ** _sage_const_2 ) + (sigma**_sage_const_2  * n -_sage_const_1 )/_sage_const_12 )
    Sigma = block_matrix([[diagonal_matrix(sigma_c), zero_matrix(n)],
                          [zero_matrix(n),(sigma ** _sage_const_2 ) * identity_matrix(n)]])
    Sigma = Sigma * d #scale dimension (may have to remove)
    our_ebdd = EBDD(identity_matrix(d), Sigma, mu, None)
    D_s = build_Gaussian_law(sigma, _sage_const_50 )
    D_e = D_s

    #Creating LWE instance used for the hints
    lwe_instance = LWE(n, q, m, D_e, D_s, is_ring = True)
    b, s, A, e_vec = (lwe_instance.b, lwe_instance.s, lwe_instance.A, lwe_instance.e_vec)
# check if need recenter or not
    b = matrix(b).apply_map(recenter) 
    A = matrix(A).apply_map(recenter)
    print(A)
    v = matrix([randint(int(-q/_sage_const_2 ), int(q/_sage_const_2 )) for i in range(n+m)])

    c = []
    #integrating hints
    for i in range(n):
        vi = concatenate([_sage_const_0 ]*i, q) #might need -q instead(?)
        vi = concatenate(vi, [_sage_const_0 ] * (n-i-_sage_const_1 ))
        vi = concatenate(vi, A[i])
        bi = b[_sage_const_0 ][i]
        ei = e_vec[_sage_const_0 ][i]

        # setting up ci
        ci1 = matrix(s[_sage_const_0 ]) * matrix(A[i]).T
        ci = -_sage_const_1 *(ci1[_sage_const_0 ,_sage_const_0 ] + ei-bi)/q
        c.append(ci)
        _ = our_ebdd.integrate_approx_hint(matrix(vi), int(bi), sigma**_sage_const_2 )

    #checking ellipsoid norm for all c||s
    u = concatenate(c, s)
    our_ebdd.u = u
    norm = scal((u - mu) * Sigma.inverse() * (u - mu).T)
    norms.append(norm)
    our_ebdd.estimate_attack()
    predicted_betas.append(our_ebdd.beta)

    # beta, delta = our_ebdd.attack()
    # calculated_betas.append(beta)
    end = time.time()
    times.append(end-start)


d = {"Predicted Beta": predicted_betas, "Norms": norms, "Times": times}
df = pd.DataFrame(data=d)
df.to_csv('fixed_ringebdd.csv', index = True)

