n = 128
m = n
i = 0

P = Primes()

for p in Primes():
    if p % (2*n) == 1:
        q = p
        i += 1 
        if i == 25:
            break
        print(q)




