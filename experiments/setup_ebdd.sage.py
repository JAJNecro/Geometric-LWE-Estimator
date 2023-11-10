

# This file was *autogenerated* from the file setup_ebdd.sage
from sage.all_cmdline import *   # import sage library

_sage_const_70 = Integer(70); _sage_const_3301 = Integer(3301); _sage_const_20 = Integer(20); _sage_const_0 = Integer(0); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_12 = Integer(12); _sage_const_50 = Integer(50)
load('../framework/LWE.sage')
load('../framework/utils.sage')

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
our_ebdd = EBDD(identity_matrix(d), Sigma, mu, None)
D_s = build_Gaussian_law(sigma, _sage_const_50 )
D_e = D_s

#Creating LWE instance used for the hints
lwe_instance = LWE(n, q, m, D_e, D_s)
b, s, A, e_vec = (lwe_instance.b, lwe_instance.s, lwe_instance.A, lwe_instance.e_vec)
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
norm = scal((u - mu) * Sigma.inverse() * (u - mu).T)
print("Solution: ", u)
print("Norm: ", norm)

#beta, delta = our_ebdd.attack()
print(our_ebdd.beta)
our_ebdd.estimate_attack()
#print(f"beta: {beta}\n{delta=}")


