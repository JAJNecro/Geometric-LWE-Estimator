load("LWE.sage")

n = 70
m = n
q = 3301
sigma = sqrt(20)
D_s = build_Gaussian_law(sigma, 50)
D_e = D_s
d = m + n
lwe_instance = LWE(n, q, m, D_e, D_s)
ebdd = lwe_instance.embed_into_EBDD()
beta, delta = ebdd.estimate_attack()

print(f"beta: {beta}\n{delta=}")

v0 = vec([randint(0, 1) for i in range(m + n)])
v1 = vec([randint(0, 1) for i in range(m + n)])
v2 = vec([randint(0, 1) for i in range(m + n)])
v3 = vec([randint(0, 1) for i in range(m + n)])           
l0, l1, l2, l3 = ebdd.leak(v0) - 1, ebdd.leak(v1) - 1, ebdd.leak(v2) - 1, ebdd.leak(v3) - 1
_ = ebdd.integrate_ineq_hint(-v0, -l0)
_ = ebdd.integrate_ineq_hint(-v1, -l1)
_ = ebdd.integrate_ineq_hint(-v2, -l2)
_ = ebdd.integrate_ineq_hint(-v3, -l3)

beta, delta = ebdd.estimate_attack()
print(f"beta: {beta}\n{delta=}")
