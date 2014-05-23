#This is my sorting program
#May god have mercy on my soul.
a = [5,3,8,4,9,2]
def sf(a):
    for b in range(1,len(a)):
        for c in range(b+1):
            if a[b] < a[c]:
                a[b],a[c] = a[c],a[b]
sf(a)
print(a)