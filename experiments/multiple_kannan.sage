#LWE embedded into EBDD instance  (using Kannan's embedding) (no hints)
load('../framework/LWE.sage')
load('../framework/utils.sage')

predicted_betas = []
calculated_betas = []
average_beta = 0
norms = []
solutions = []

num_experiments = 200
for x in range(num_experiments):
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
    beta, delta = ebdd_with_lwe.attack() 
    print(f"beta: {beta}\n")
