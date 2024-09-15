

# This file was *autogenerated* from the file ebdd_cluster.sage
from sage.all_cmdline import *   # import sage library

_sage_const_1 = Integer(1); _sage_const_2 = Integer(2); _sage_const_100 = Integer(100); _sage_const_0 = Integer(0); _sage_const_70 = Integer(70); _sage_const_3301 = Integer(3301); _sage_const_20 = Integer(20); _sage_const_12 = Integer(12); _sage_const_50 = Integer(50)
load('../framework/LWE.sage')
load('../framework/utils.sage')

import pandas as pd
import time
from numpy.random import seed as np_seed

try:
    nb_tests = int(sys.argv[_sage_const_1 ])
    ring = int(sys.argv[_sage_const_2 ])
except:
    nb_tests = _sage_const_100  
    ring = _sage_const_0 


def one_experiment():
    set_random_seed()

    ebdd_predicted_betas_normal = []
    ebdd_predicted_betas_prob = []
    ebdd_calculated_betas = []
    ebdd_norms = []
    kannan_predicted_betas_normal = []
    kannan_predicted_betas_prob = []
    kannan_calculated_betas = []
    kannan_norms = []
    times = []

    start = time.time()
    n = _sage_const_70 
    m = n
    q = _sage_const_3301 
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
    our_ebdd = EBDD(identity_matrix(d), Sigma, mu, None, calibrate_volume = False)
    D_s = build_Gaussian_law(sigma, _sage_const_50 )
    D_e = D_s

    #Creating LWE instance used for the hints
    if ring == _sage_const_1 :
        lwe_instance = LWE(n, q, m, D_e, D_s, is_ring = True)
    else:
        lwe_instance = LWE(n, q, m, D_e, D_s, is_ring = False)

    b, s, A, e_vec = (lwe_instance.b, lwe_instance.s, lwe_instance.A, lwe_instance.e_vec)

    # Custom Embedding
    b = matrix(b).apply_map(recenter)
    A = matrix(A).apply_map(recenter)
    v = matrix([randint(int(-q/_sage_const_2 ), int(q/_sage_const_2 )) for i in range(n+m)])

    c = []
    #integrating hints
    print(s)
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
    norm = our_ebdd.ellip_norm()/d
    #norm = scal((u - mu) * Sigma.inverse() * (u - mu).T)
    ebdd_norms.append(norm)
    our_ebdd.estimate_attack()
    ebdd_predicted_betas_normal.append(our_ebdd.beta)
    our_ebdd.estimate_attack(probabilistic = True)
    ebdd_predicted_betas_prob.append(our_ebdd.beta)

    beta, delta = our_ebdd.attack()
    ebdd_calculated_betas.append(beta)



    # Kannan's Embedding
    D_s = build_Gaussian_law(sigma, _sage_const_50 )
    D_e = D_s

    #embedding into EBDD
    ebdd_with_lwe = lwe_instance.embed_into_EBDD()

    #getting u, norm, and predicted betas
    u = concatenate(lwe_instance.s, lwe_instance.e_vec)
    norm = scal(matrix(u) * matrix(u.T))/((n+m)*sigma**_sage_const_2 ) 
    kannan_norms.append(float(norm)) 
    ebdd_with_lwe.estimate_attack()
    kannan_predicted_betas_normal.append(ebdd_with_lwe.beta)
    ebdd_with_lwe.estimate_attack(probabilistic = True)
    kannan_predicted_betas_prob.append(ebdd_with_lwe.beta)

    beta, delta = ebdd_with_lwe.attack() 
    kannan_calculated_betas.append(beta)

    end = time.time()
    times.append(end-start)


    d = {"EBDD Normal Predicted Beta": ebdd_predicted_betas_normal, "EBDD Probabilistic Predicted Beta": ebdd_predicted_betas_prob, "EBDD Calculated Beta": ebdd_calculated_betas, "EBDD Norms": ebdd_norms, "Kannan Normal Predicted Beta": kannan_predicted_betas_normal, "Kannan Prob Predicted Beta": kannan_predicted_betas_prob, "Kannan Calculated Beta": kannan_calculated_betas, "Kannan Norms": kannan_norms, "Times": times}
    df = pd.DataFrame(data=d)
    df.to_csv('ebdd_cluster.csv', index = True)


def run_experiment(num_experiments):
    for i in range(num_experiments):
        one_experiment()

run_experiment(nb_tests)

