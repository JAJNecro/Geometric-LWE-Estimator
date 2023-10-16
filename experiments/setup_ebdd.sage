load('../framework/LWE.sage')
load('../framework/utils.sage')

n = 70
m = n
q = 3301
sigma = sqrt(20)
sigma_c = []
mu = concatenate([0] * (m+n), [])
d = m + n
for i in range(0, n):
    sigma_c.append(((sigma / q) ** 2) + (sigma**2 * n -1)/12)
Sigma = block_matrix([[diagonal_matrix(sigma_c), zero_matrix(n)],
                      [zero_matrix(n),(sigma ** 2) * identity_matrix(n)]])
Sigma = Sigma * d
our_ebdd = EBDD(identity_matrix(d), Sigma, mu, None)
D_s = build_Gaussian_law(sigma, 50)
D_e = D_s
lwe_instance = LWE(d, q, d, D_e, D_s)
b, s, A, e_vec = (lwe_instance.b, lwe_instance.s, lwe_instance.A, lwe_instance.e_vec)
b = matrix(b).apply_map(recenter)
A = matrix(A).apply_map(recenter)
# v = matrix([randint(int(-q/2), int(q/2)) for i in range(n+m)])
#for i in range(n):
#    vi = concatenate([0]*i, q)
#    vi = concatenate(vi, [0] * (n-i))
#    vi = concatenate(A[i])
#    _ = our_ebdd.integrate_approx_hint(matrix(vi), b[0][i], sigma**2)

# beta, delta = our_ebdd.attack()
# print(f"beta: {beta}\n{delta=}")

lwe_instance = LWE(m, q, n, D_e, D_s)
ebdd_with_lwe = lwe_instance.embed_into_EBDD()
beta, delta = ebdd_with_lwe.attack() #experimentally get BKZ51 with beta: 51
print(f"beta: {beta}\n{delta=}")
