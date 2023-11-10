#LWE embedded into EBDD instance  (using Kannan's embedding) (no hints)
import numpy as np
import pandas as pd
import time
load('../framework/LWE.sage')
load('../framework/utils.sage')

times = []
predicted_betas = []
calculated_betas = []
solutions = []

num_experiments = 200
for x in range(num_experiments):
    start = time.time()
    print("========================================== Experiment: " + str(x) + "=========================================")
    n = 70
    m = n
    q = 3301
    sigma = sqrt(20)
    sigma_c = []
    mu = concatenate([0] * (m+n), [])
    d = m + n
    D_s = build_Gaussian_law(sigma, 50)
    D_e = D_s

    lwe_instance = LWE(m, q, n, D_e, D_s)
    ebdd_with_lwe = lwe_instance.embed_into_EBDD()
    ebdd_with_lwe.estimate_attack()
    predicted_betas.append(ebdd_with_lwe.beta)
    solutions.append(ebdd_with_lwe.u)

    beta, delta = ebdd_with_lwe.attack() 
    calculated_betas.append(beta)
    end = time.time()
    times.append(end-start)

d = {"Predicted Beta": predicted_betas, "Calculated Beta": calculated_betas, "Times": times}
df = pd.DataFrame(data=d)
df.to_csv('200kannan.csv', index = True)
