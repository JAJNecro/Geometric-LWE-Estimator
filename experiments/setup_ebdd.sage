load('../framework/LWE.sage')
load('../framework/utils.sage')

n = 70
m = n
q = 3301
sigma = sqrt(20)
sigma_c = []
mu = concatenate([0] * (m+n), [])
d = m + n

#Setting up Sigma
for i in range(0, n):
    sigma_c.append(((sigma / q) ** 2) + (sigma**2 * n -1)/12)
Sigma = block_matrix([[diagonal_matrix(sigma_c), zero_matrix(n)],
                      [zero_matrix(n),(sigma ** 2) * identity_matrix(n)]])
#Sigma = Sigma * d #scale dimension (may have to remove)
our_ebdd = EBDD(identity_matrix(d), Sigma, mu, None)
D_s = build_Gaussian_law(sigma, 50)
D_e = D_s

#Creating LWE instance used for the hints
lwe_instance = LWE(n, q, m, D_e, D_s)
b, s, A, e_vec = (lwe_instance.b, lwe_instance.s, lwe_instance.A, lwe_instance.e_vec)
b = matrix(b).apply_map(recenter)
A = matrix(A).apply_map(recenter)
v = matrix([randint(int(-q/2), int(q/2)) for i in range(n+m)])

c = []
#integrating hints
print(s)
for i in range(n):
    vi = concatenate([0]*i, q)
    vi = concatenate(vi, [0] * (n-i-1))
    vi = concatenate(vi, A[i])
    bi = b[0][i]
    ei = e_vec[0][i]

    # setting up ci
    ci = (s[0] * A[i] + ei-bi)/q
    c.append(ci)
    _ = our_ebdd.integrate_approx_hint(matrix(vi), int(bi), sigma**2)

#checking ellipsoid norm for all c||s
u = concatenate(c, s)
norm = scal((u - mu) * Sigma.inverse() * (u - mu).T)
print(norm)

beta, delta = our_ebdd.attack()
print(f"beta: {beta}\n{delta=}")

# LWE embedded into EBDD instance  (using Kannan's embedding) (no hints)
#lwe_instance = LWE(m, q, n, D_e, D_s)
#ebdd_with_lwe = lwe_instance.embed_into_EBDD()
#beta, delta = ebdd_with_lwe.attack() #experimentally get BKZ51 with beta: 51
#print(f"beta: {beta}\n{delta=}")
