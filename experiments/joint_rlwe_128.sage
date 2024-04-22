load('../framework/LWE.sage')
load('../framework/utils.sage')
import pandas as pd
import time

ebdd_predicted_betas_normal = []
ebdd_predicted_betas_prob = []
ebdd_calculated_betas = []
ebdd_norms = []
kannan_predicted_betas_normal = []
kannan_predicted_betas_prob = []
kannan_calculated_betas = []
kannan_norms = []
times = []

num_experiments = 100
for x in range(num_experiments):
    start = time.time()
    print("========================================== Experiment: " + str(x) + "=========================================")
    n = 128
    m = n
    q = 3329
    sigma = sqrt(3/2)
    sigma_c = []
    mu = concatenate([0] * (m+n), [])
    d = m + n

    #Setting up Sigma
    for i in range(0, n):
        sigma_c.append(((sigma / q) ** 2) + (sigma**2 * n -1)/12)
    Sigma = block_matrix([[diagonal_matrix(sigma_c), zero_matrix(n)],
                          [zero_matrix(n),(sigma ** 2) * identity_matrix(n)]])
    Sigma = Sigma * d #scale dimension (may have to remove)
    our_ebdd = EBDD(identity_matrix(d), Sigma, mu, None, calibrate_volume = False)
    D_s = build_Gaussian_law(sigma, 50)
    D_e = D_s

    #Creating LWE instance used for the hints
    lwe_instance = LWE(n, q, m, D_e, D_s, is_ring = True)
    b, s, A, e_vec = (lwe_instance.b, lwe_instance.s, lwe_instance.A, lwe_instance.e_vec)

    # Custom Embedding
    b = matrix(b).apply_map(recenter)
    A = matrix(A).apply_map(recenter)
    v = matrix([randint(int(-q/2), int(q/2)) for i in range(n+m)])

    c = []
    #integrating hints
    print(s)
    for i in range(n):
        vi = concatenate([0]*i, q) #might need -q instead(?)
        vi = concatenate(vi, [0] * (n-i-1))
        vi = concatenate(vi, A[i])
        bi = b[0][i]
        ei = e_vec[0][i]

        # setting up ci
        ci1 = matrix(s[0]) * matrix(A[i]).T
        ci = -1*(ci1[0,0] + ei-bi)/q
        c.append(ci)
        _ = our_ebdd.integrate_approx_hint(matrix(vi), int(bi), sigma**2)

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


    try:
        beta, delta = our_ebdd.attack()
    except:
        beta, delta = 0
        print("error")
    ebdd_calculated_betas.append(beta)

    # Kannan's Embedding
    D_s = build_Gaussian_law(sigma, 50)
    D_e = D_s

    #embedding into EBDD
    ebdd_with_lwe = lwe_instance.embed_into_EBDD()

    #getting u, norm, and predicted betas
    u = concatenate(lwe_instance.s, lwe_instance.e_vec)
    norm = scal(matrix(u) * matrix(u.T))/((n+m)*sigma**2) 
    kannan_norms.append(float(norm)) 
    ebdd_with_lwe.estimate_attack()
    kannan_predicted_betas_normal.append(ebdd_with_lwe.beta)
    ebdd_with_lwe.estimate_attack(probabilistic = True)
    kannan_predicted_betas_prob.append(ebdd_with_lwe.beta)

    try:
        beta, delta = ebdd_with_lwe.attack() 
    except:
        beta, delta = 0
        print("error")
    kannan_calculated_betas.append(beta)

    end = time.time()
    times.append(end-start)


d = {"EBDD Normal Predicted Beta": ebdd_predicted_betas_normal, "EBDD Probabilistic Predicted Beta": ebdd_predicted_betas_prob, "EBDD Calculated Beta": ebdd_calculated_betas, "EBDD Norms": ebdd_norms, "Kannan Normal Predicted Beta": kannan_predicted_betas_normal, "Kannan Prob Predicted Beta": kannan_predicted_betas_prob, "Kannan Calculated Beta": kannan_calculated_betas, "Kannan Norms": kannan_norms, "Times": times}
df = pd.DataFrame(data=d)
df.to_csv('error_joint_rlwe.csv', index = True)