import time

t=time.time()
def needle(a, b, gapopen, gapextend, endgapopen, endgapextend):
    def E_FPEQ(a, b, e): return (((b - e) < a) & (a < (b + e)))

    sub = [[5, -4, -4, -4, -4, 1, 1, -4, -4, 1, -4, -1, -1, -1, -2, -4], [-4, 5, -4, -4, -4, 1, -4, 1, 1, -4, -1, -4, -1, -1, -2, 5], [-4, -4, 5, -4, 1, -4, 1, -4, 1, -4, -1, -1, -4, -1, -2, -4], [-4, -4, -4, 5, 1, -4, -4, 1, -4, 1, -1, -1, -1, -4, -2, -4], [-4, -4, 1, 1, -1, -4, -2, -2, -2, -2, -1, -1, -3, -3, -1, -4], [1, 1, -4, -4, -4, -1, -2, -2, -2, -2, -3, -3, -1, -1, -1, 1], [1, -4, 1, -4, -2, -2, -1, -4, -2, -2, -3, -1, -3, -1, -1, -4], [-4, 1, -4, 1, -2, -2, -4, -1, -2, -2, -1, -3, -1, -3, -1, 1], [-4, 1, 1, -4, -2, -2, -2, -2, -1, -4, -1, -3, -3, -1, -1, 1], [1, -4, -4, 1, -2, -2, -2, -2, -4, -1, -3, -1, -1, -3, -1, -4], [-4, -1, -1, -1, -1, -3, -3, -1, -1, -3, -1, -2, -2, -2, -1, -1], [-1, -4, -1, -1, -1, -3, -1, -3, -3, -1, -2, -1, -2, -2, -1, -4], [-1, -1, -4, -1, -3, -1, -3, -1, -3, -1, -2, -2, -1, -2, -1, -1], [-1, -1, -1, -4, -3, -1, -1, -3, -1, -3, -2, -2, -2, -1, -1, -1], [-2, -2, -2, -2, -1,-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2], [-4, 5, -4, -4, -4, 1, -4, 1, 1, -4, -1, -4, -1, -1, -2, 5]]; # EDNAFUL

    base_to_idx = {'A': 0, 'C': 3, 'B': 10, 'D': 13, 'G': 2, 'H': 12, 'K': 8, 'M': 9, 'N': 14, 'S': 4, 'R': 6, 'U': 15, 'T': 1, 'W': 5, 'V': 11, 'Y': 7}; # for EDNAFULL
    idx_to_base = {0: 'A', 1: 'T', 2: 'G', 3: 'C', 4: 'S', 5: 'W', 6: 'R', 7: 'Y', 8: 'K', 9: 'M', 10: 'B', 11: 'V', 12: 'H', 13: 'D', 14: 'N', 15: 'U'}; # for EDNAFULL

    ix = {}
    iy = {}
    m = {}

    compass = {}
    p = []
    q = []

    lena = len(a)
    lenb = len(b)

    
    for i in range(lena): p.append(base_to_idx[a[i]])
    for i in range(lenb): q.append(base_to_idx[b[i]])

    match = sub[p[0]][q[0]]
    
    aln_a = []
    aln_b = []
    aln_r = []

    ix[0] = -endgapopen-gapopen
    iy[0] = -endgapopen-gapopen
    m[0] = match
    
    for ypos in range(1, lena):
        match = sub[p[ypos]][q[0]]
        cursor = ypos * lenb
        cursorp = (ypos - 1) * lenb

        testog = m[cursorp] - gapopen
        testeg = iy[cursorp] - gapopen

        if testog >= testeg: iy[cursor] = testog
        else: iy[cursor] = testeg

        m[cursor] = match - (endgapopen + (ypos - 1) * endgapextend)
        ix[cursor] = -endgapopen - ypos * endgapextend - gapopen

    ix[cursor] -= endgapopen
    ix[cursor] += gapopen
    
    cursor = 0

    for xpos in range(1, lenb):
        match = sub[p[0]][q[xpos]]
        cursor = xpos
        cursorp = xpos - 1

        testog = m[cursorp] - gapopen
        testeg = ix[cursorp] - gapextend
        
        if testog >= testeg: ix[cursor] = testog
        else: ix[cursor] = testeg

        m[cursor] = match - (endgapopen + (xpos - 1) * endgapextend)
        iy[cursor] = -endgapopen - xpos * endgapextend - gapopen

    iy[cursor] -= endgapopen
    iy[cursor] += gapopen

    xpos = 1
    
    while xpos != lenb:
        ypos = 1
        bconvcode = q[xpos]
        
        cursorp = xpos - 1
        cursor = xpos

        xpos+=1

        while (ypos < lena):

            match = sub[p[ypos]][bconvcode]
            ypos += 1
            cursor += lenb

            mp = m[cursorp]
            ixp = ix[cursorp]
            iyp = iy[cursorp]

            if (mp > ixp and mp > iyp): m[cursor] = mp + match
            elif ixp > iyp: m[cursor] = ixp + match
            else: m[cursor] = iyp + match

            cursorp += 1

            if xpos == lenb:
                testog = m[cursorp] - endgapopen
                testeg = iy[cursorp] - endgapextend
            else:
                testog = m[cursorp]
                if testog < ix[cursorp]: testog = ix[cursorp]

                testog -= gapopen
                testeg = iy[cursorp] - gapextend

            if testog > testeg: iy[cursor] = testog
            else: iy[cursor] = testeg
            
            cursorp += lenb

            cursorp -= 1

            if ypos == lena:
                testog = m[cursorp] - endgapopen
                testeg = ix[cursorp] -endgapextend
            else:
                testog = m[cursorp]
                if testeg < iy[cursorp]: testog = iy[cursorp]
                testog -= gapopen
                testeg = ix[cursorp] - gapextend
            if testog > testeg: ix[cursor] = testog
            else: ix[cursor] =testeg
        
    score = -32767 # INT MIN
    start1 = lena - 1
    start2 = lenb - 1

    cursor = lena * lenb - 1
    if m[cursor] > ix[cursor] and m[cursor] > iy[cursor]: score = m[cursor]
    elif ix[cursor] > iy[cursor]: score = ix[cursor]
    else: score = iy[cursor]

    cursorp = 0
    cursor = 1

    eps = 1.192e-6

    ypos = start1
    xpos = start2
    


    while xpos >= 0 and ypos >= 0:
        cursor = ypos * lenb + xpos
        mp = m[cursor]

        if ypos == 0 or ypos == lena - 1: FPEQ_a1 = endgapextend
        else: FPEQ_a1 = gapextend
        
        if xpos == 0 or xpos == lenb - 1: FPEQ_a2 = endgapextend
        else: FPEQ_a2 = gapextend

        if cursorp == 1 and E_FPEQ(FPEQ_a1, ix[cursor]-ix[cursor+1], eps):
            compass[cursor] = 1
            xpos -= 1
        elif cursorp == 2 and E_FPEQ(FPEQ_a2, iy[cursor]-iy[cursor+lenb], eps):
            compass[cursor] = 2
            ypos -= 1
        elif mp >= ix[cursor] and mp >= iy[cursor]:
            if cursorp == 1 and E_FPEQ(mp, ix[cursor], eps):
                compass[cursor] = 1
                xpos -= 1
            elif cursorp == 2 and E_FPEQ(mp, iy[cursor], eps):
                compass[cursor] = 2
                ypos -= 1
            else:
                compass[cursor] = 0
                ypos -= 1
                xpos -= 1
        elif ix[cursor] >= iy[cursor] and xpos > -1:
            compass[cursor] = 1
            xpos -= 1
        elif ypos > -1:
            compass[cursor] = 2
            ypos -= 1
        else:
            print("Needle: Something is seriously wrong in the traceback algorithm")
            return -1
        
        cursorp = compass[cursor]

    for i in range(lenb-1, start2, -1):
        aln_b.append(idx_to_base[q[i]])
        aln_a.append('-')
        aln_r.append(' ')
    for j in range(lena-1, start1, -1):
        aln_a.append(idx_to_base[p[j]])
        aln_b.append('-')
        aln_r.append(' ')

    while start2 >= 0 and start1 >= 0:
        cursor = start1 * lenb + start2
        if compass[cursor] == 0: # diagonal
            b1 = p[start1]
            b2 = q[start2]
            start1 -= 1
            start2 -= 1
            aln_a.append(idx_to_base[b1])
            aln_b.append(idx_to_base[b2])
            if b1 == b2: aln_r.append('|')
            else: aln_r.append('.')
            continue
        elif compass[cursor] == 1: # Left, gap(s) in vertical
            aln_a.append('-')
            aln_b.append(idx_to_base[q[start2]])
            aln_r.append(' ')
            start2 -= 1
            continue
        elif compass[cursor] == 2: # Down, gap(s) in horizontal
            aln_a.append(idx_to_base[p[start1]])
            aln_b.append('-')
            aln_r.append(' ')
            start1 -= 1
            continue
        else:
            print(compass)
            print("Needle: Walk Error in WN")
            return -1

    for i in range(start2, -1, -1):
        aln_b.append(idx_to_base[q[i]])
        aln_a.append('-')
        aln_r.append(' ')

    for i in range(start1, -1, -1):
        aln_a.append(idx_to_base[p[i]])
        aln_b.append('-')
        aln_r.append(' ')

    aln_a = "".join(aln_a[::-1])
    aln_b = "".join(aln_b[::-1])
    aln_r = "".join(aln_r[::-1])
    
    return [aln_a, aln_r, aln_b]
