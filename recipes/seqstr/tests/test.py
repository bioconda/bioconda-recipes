from seqstr import seqstr
test = ['[hg38]chr7:5480600-5480620 +',#base
        'chr7:5480600-5480620 -',#base rev
        '[hg38]chr7:5480600-5480620 +, @chr7 5480600 T TA',#insertion
        '[hg38]chr7:5480600-5480620 +, @chr7 5480600 TT T',#deletion
        '[hg38]chr7:5480600-5480620 +, @chr7 5480600 TT T, @chr7 5480619 A AT',#indel
        '[hg38]chr7:5480600-5480620 +, @chr7 5480600 TT T, @chr7 5480619 A AT;TATA;',#indel,concat
        '[hg38]chr7:5480600-5480610 +, @chr7 5480600 TT T;TATA;[hg38]chr7:5480610-5480620 +, @chr7 5480619 A AT;',#indel,concat,indel
        'CG;[hg38]chr7:5480600-5480620 +, @chr7 5480619 A AT, @chr7 5480600 TT T;TA;',#concat,indel,concat
        'CG;[hg38]chr7:5480600-5480610 +, @chr7 5480600 TT T;TA;[hg38]chr7:5480610-5480620 +, @chr7 5480619 A AT',#concat,indel,concat,indel
        '[hg38]chr7:5480600-5480620 -, @chr7 5480600 T TA',#insertion rev
        '[hg38]chr7:5480600-5480620 -, @chr7 5480600 TT T',#deletion rev
        '[hg38]chr7:5480600-5480620 -, @chr7 5480600 TT T, @chr7 5480619 A AT',#indel rev
        '[hg38]chr7:5480600-5480620 -, @chr7 5480600 TT T, @chr7 5480619 A AT;TATA;',#indel rev,concat
        '[hg38]chr7:5480600-5480610 -, @chr7 5480600 TT T;TATA;[hg38]chr7:5480610-5480620 -, @chr7 5480619 A AT;',#indel rev,concat,indel rev
        '[hg38]chr7:5480600-5480610 -, @chr7 5480600 TT T;TATA;[hg38]chr7:5480610-5480620 +, @chr7 5480619 A AT;',#indel rev,concat,indel
        '[hg38]chr7:5480600-5480610 +, @chr7 5480600 TT T;TATA;[hg38]chr7:5480610-5480620 -, @chr7 5480619 A AT;',#indel,concat,indel rev
        #spacing
        '[hg38]chr7:5480600-5480610  + , @chr7  5480600  TT  T ; TATA ; [hg38]chr7:5480610-5480620  + , @chr7  5480619  A  AT ;',
        #errors
        " chr:5480600-5580600 -"," chr7:548060A-5480620 -"," chr7:5480600-5480620 A",
            "chr7:5480600-5480620 -, @chr7 548060A TT T",
            "chr7:5480600-5480620 -, @chr7 5480600 TT",
            "chr7:5480600-5480620 -, @chr7 5480600 TT T, @chr7 5480601 T A",
            ]
result = []
ans = ['TTGTCCAGGCTGGAGTGCAA',#base
      'TTGCACTCCAGCCTGGACAA',#base rev
      'TATGTCCAGGCTGGAGTGCAA',#insertion
      'TGTCCAGGCTGGAGTGCAA',#deletion
      'TGTCCAGGCTGGAGTGCAAT',#indel
      'TGTCCAGGCTGGAGTGCAATTATA',#indel,concat
      'TGTCCAGGCTATATGGAGTGCAAT',#indel,concat,indel
      'CGTGTCCAGGCTGGAGTGCAATTA',#concat,indel,concat
      'CGTGTCCAGGCTATGGAGTGCAAT',#concat,indel,concat,indel
      'TTGCACTCCAGCCTGGACATA',#insertion rev
      'TTGCACTCCAGCCTGGACA',#deletion rev
      'ATTGCACTCCAGCCTGGACA',#indel rev
      'ATTGCACTCCAGCCTGGACATATA',#indel rev,concat
      'GCCTGGACATATAATTGCACTCCA',#indel rev,concat,indel rev
      'GCCTGGACATATATGGAGTGCAAT',#indel rev,concat,indel
      'TGTCCAGGCTATAATTGCACTCCA',#indel,concat,indel rev
      'TGTCCAGGCTATATGGAGTGCAAT'#spacing
      ]
text = '\n'.join(test)
seqstrout = seqstr(text)
for i,item in enumerate(seqstrout):
    if item.errormsg != '':
        print(item.Name," test passes and error message is:",item.errormsg)
    else:
        if item.Seq != ans[i]:
            print(item.Name,' test result:',item.Seq,',correct ans:',ans[i])
        else:
            print(item.Name,' test passes')