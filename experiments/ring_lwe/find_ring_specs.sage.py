

# This file was *autogenerated* from the file find_ring_specs.sage
from sage.all_cmdline import *   # import sage library

_sage_const_128 = Integer(128); _sage_const_0 = Integer(0); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_25 = Integer(25)
n = _sage_const_128 
m = n
i = _sage_const_0 

P = Primes()

for p in Primes():
    if p % (_sage_const_2 *n) == _sage_const_1 :
        q = p
        i += _sage_const_1  
        if i == _sage_const_25 :
            break
        print(q)





