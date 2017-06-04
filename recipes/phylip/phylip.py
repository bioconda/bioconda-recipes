#!/usr/bin/env python
#
# Wrapper script for phylip program when installed from
# bioconda. Adapted from shell scripts provided in the biolbuilds
# conda recipe by Cheng H. Lee.

import sys
import os
import subprocess

def main():
    print("running main")
    print(sys.argv)
    bindir = get_script_path(sys.argv[0])
    sharedir= get_script_path(bindir+"/dnapars")
    print(sharedir)
    if len(sys.argv) == 1:
        print("Usage: {prog} <program>".format(prog=sys.argv[0]))
        print("Existing programs are: {progs}".format(progs=os.listdir(sharedir)))
        sys.exit(1)

    progname = sys.argv[1]

    if progname == "test": # hidden test of conda phylip installation
        test(bindir)
    elif(os.path.isfile(program)):
        program = bindir+"/"+progname
        subprocess.run(program, check=True)
    else:
        print("{prog} does not exist in Phylip".format(prog=progname))
        usage()
        sys.exit(1)


def usage():
    print("Usage: {prog} <program>".format(prog=sys.argv[0]))
    print("Existing programs are: {progs}".format(progs=os.listdir(bindir)))

              
def get_script_path(script):
    return os.path.dirname(os.path.realpath(script))

# Main function for testing the conda installation of phylip
# This simply tests that phylip can process infiles without without error code
def test(bindir):
    params = "0\ny\n"
    out = open("infile", "wt")
    out.write(infiles["testdna"])
    out.close()
    for prog in ["dnapars","dnaml","dnadist","dnapenny","dnacomp","dnamlk"]: #,"dnainvar"
        testprog(prog, bindir,params)
    out = open("infile", "wt")
    out.write(infiles["testprot"])
    out.close()
    for prog in ["protpars","protdist","proml","promlk"]:
        testprog(prog, bindir, params)
    out = open("infile", "wt")
    out.write(infiles["testdisc"])
    out.close()
    for prog in ["pars","penny","dollop","dolpenny","clique","mix"]: 
        testprog(prog, bindir,params)
    out = open("infile", "wt")
    out.write(infiles["testrest"])
    out.close()
    for prog in ["restml","restdist"]:
        testprog(prog, bindir, params)
    out = open("infile", "wt")
    out.write(infiles["testdist"])
    out.close()
    for prog in ["fitch","kitsch","neighbor"]:
        testprog(prog, bindir,params)
    out = open("intree", "wt")
    out.write(infiles["testtree"])
    out.close()
    for prog in ["drawtree", "drawgram"]:
        params = "0\nl\nm\ny\n"
        testprog(prog, bindir,params)
    # testing the java gui versions require user interaction
    # Not good for automatic istallations -- comment out for now,
    # but keep for debug?
'''    for prog in ["drawtree_gui", "drawgram_gui"]:
        print("testing " + prog)
        program = bindir+"/"+prog
        outfile = open(prog+".out",'wt')
        try:
            subprocess.run(program, universal_newlines=True,input=params,stdout=outfile, stderr=subprocess.PIPE, check=True)
        except subprocess.CalledProcessError as e:
            print(e)
            subprocess.call(["cat", prog+".out"], shell=True)
            raise
        print("passed; cleaning up")
        subprocess.call(["rm", "-f", "infile","plotfile.ps"])'''

# Help function for testing the conda installation of phylip
def testprog(prog, bindir, params):
    print("testing " + prog + "...",)
    program = bindir+"/"+prog
    outfile = open(prog+".out",'wt')
    try:
        subprocess.run(program, universal_newlines=True,input=params,stdout=outfile, check=True)
    except subprocess.CalledProcessError as e:
        print(e)
        subprocess.call(["cat", prog+".out"])
        raise
    print("passed; cleaning up")
    subprocess.call(["rm", "-f", "outtree", "outfile", "plotfile"])

    
# Content of test files for testing the conda installation of phylip        
infiles = {
    "testdna" :
    """    7  232
Bovine    CCAAACCTGT CCCCACCATC TAACACCAAC CCACATATAC AAGCTAAACC AAAAATACCA
Mouse     CCAAAAAAAC ATCCAAACAC CAACCCCAGC CCTTACGCAA TAGCCATACA AAGAATATTA
Gibbon    CTATACCCAC CCAACTCGAC CTACACCAAT CCCCACATAG CACACAGACC AACAACCTCC
Orang     CCCCACCCGT CTACACCAGC CAACACCAAC CCCCACCTAC TATACCAACC AATAACCTCT
Gorilla   CCCCATTTAT CCATAAAAAC CAACACCAAC CCCCATCTAA CACACAAACT AATGACCCCC
Chimp     CCCCATCCAC CCATACAAAC CAACATTACC CTCCATCCAA TATACAAACT AACAACCTCC
Human     CCCCACTCAC CCATACAAAC CAACACCACT CTCCACCTAA TATACAAATT AATAACCTCC

          TACTACTAAA AACTCAAATT AACTCTTTAA TCTTTATACA ACATTCCACC AACCTATCCA
          TACAACCATA AATAAGACTA ATCTATTAAA ATAACCCATT ACGATACAAA ATCCCTTTCG
          CACCTTCCAT ACCAAGCCCC GACTTTACCG CCAACGCACC TCATCAAAAC ATACCTACAA
          CAACCCCTAA ACCAAACACT ATCCCCAAAA CCAACACACT CTACCAAAAT ACACCCCCAA
          CACCCTCAAA GCCAAACACC AACCCTATAA TCAATACGCC TTATCAAAAC ACACCCCCAA
          CACTCTTCAG ACCGAACACC AATCTCACAA CCAACACGCC CCGTCAAAAC ACCCCTTCAG
          CACCTTCAGA ACTGAACGCC AATCTCATAA CCAACACACC CCATCAAAGC ACCCCTCCAA

          CACAAAAAAA CTCATATTTA TCTAAATACG AACTTCACAC AACCTTAACA CATAAACATA
          TCTAGATACA AACCACAACA CACAATTAAT ACACACCACA ATTACAATAC TAAACTCCCA
          CACAAACAAA TGCCCCCCCA CCCTCCTTCT TCAAGCCCAC TAGACCATCC TACCTTCCTA
          TTCACATCCG CACACCCCCA CCCCCCCTGC CCACGTCCAT CCCATCACCC TCTCCTCCCA
          CATAAACCCA CGCACCCCCA CCCCTTCCGC CCATGCTCAC CACATCATCT CTCCCCTTCA
          CACAAATTCA TACACCCCTA CCTTTCCTAC CCACGTTCAC CACATCATCC CCCCCTCTCA
          CACAAACCCG CACACCTCCA CCCCCCTCGT CTACGCTTAC CACGTCATCC CTCCCTCTCA

          CCCCAGCCCA ACACCCTTCC ACAAATCCTT AATATACGCA CCATAAATAA CA
          TCCCACCAAA TCACCCTCCA TCAAATCCAC AAATTACACA ACCATTAACC CA
          GCACGCCAAG CTCTCTACCA TCAAACGCAC AACTTACACA TACAGAACCA CA
          ACACCCTAAG CCACCTTCCT CAAAATCCAA AACCCACACA ACCGAAACAA CA
          ACACCTCAAT CCACCTCCCC CCAAATACAC AATTCACACA AACAATACCA CA
          ACATCTTGAC TCGCCTCTCT CCAAACACAC AATTCACGCA AACAACGCCA CA
          ACACCTTAAC TCACCTTCTC CCAAACGCAC AATTCGCACA CACAACGCCA CA
""",
    "testprot" :
    """     3    474
CAM        ---TTETIQS NANLAPLPPH VPEHLVFDFD MYNPSN--LS AGVQEAWAVL 
TERP       ----MDARAT IPEHIARTVI LPQGYADDEV IYPAFK--WL RDEQPLAMAH 
BM3        TIKEMPQPKT FGELKNLPLL NTDKPVQALM KIADELGEIF KFEAPGRVTR 

           QESNVPDLVW TRCNGG---H WIATRGQLIR EAY-EDYRHF SSECPFIPRE 
           IEGYDPMWIA TKHADV---M QIGKQPGLFS NAEGSEILYD QNNEAFMRSI 
           YLS-SQRLIK EACDESRFDK NLSQALKFVR DFAGDGLFTS WTHEKNWKKA 

           AGEAYDFIP- -TSMDPPEQR QFRALANQVV GMPVVDKLEN RIQELACSLI 
           SGGCPHVIDS LTSMDPPTHT AYRGLTLNWF QPASIRKLEE NIRRIAQASV 
           HNILLPSFS- -QQAMKGYHA MMVDIAVQLV QKWERLNADE HIEVPEDMTR 

           ESLR-PQGQC NFTEDYAEPF PIRIFMLLAG LPEEDIPHLK YLTDQMT--- 
           QRLLDFDGEC DFMTDCALYY PLHVVMTALG VPEDDEPLML KLTQDFFGVH 
           LTLD-TIGLC GFNYRFNSFY RDQPHPFITS MVRALDEAMN KLQRANP--D 

           RPD------- ------GSMT FAEAKEALYD YLIPIIEQRR QKP--GTDAI 
           EPDEQAVAAP RQSADEAARR FHETIATFYD YFNGFTVDRR SCP--KDDVM 
           DPAYD----- -----ENKRQ FQEDIKVMND LVDKIIADRK ASGEQSDDLL 

           SIVANGQVN- -GRPITSDEA KRMCGLLLVG GLDTVVNFLS FSMEFLAKSP 
           SLLANSKLD- -GNYIDDKYI NAYYVAIATA GHDTTSSSSG GAIIGLSRNP 
           THMLNGKDPE TGEPLDDENI RYQIITFLIA GHETTSGLLS FALYFLVKNP 

           EHRQELIERP E--------- --------RI PAACEELLRR FS-LVADGRI 
           EQLALAKSDP A--------- --------LI PRLVDEAVRW TAPVKSFMRT 
           HVLQKAAEEA ARVLVDPVPS YKQVKQLKYV GMVLNEALRL WPTAPAFSLY 

           LTSDYEFHGV Q-LKKGDQIL LPQMLSGLDE REN-ACPMHV DFSRQK---- 
           ALADTEVRGQ N-IKRGDRIM LSYPSANRDE EVF-SNPDEF DITRFP---- 
           AKEDTVLGGE YPLEKGDELM VLIPQLHRDK TIWGDDVEEF RPERFENPSA 

           ---VSHTTFG HGSHLCLGQH LARREIIVTL KEWLTRIPDF SIAPGAQIQH 
           ---NRHLGFG WGAHMCLGQH LAKLEMKIFF EELLPKLKSV ELS-GPPRLV 
           IPQHAFKPFG NGQRACIGQQ FALHEATLVL GMMLKHFDFE DHT-NYELDI 

           KSGIVSGVQA LPLVWDPATT KAV-
           ATNFVGGPKN VPIRFTKA-- ----
           KETLTLKPEG FVVKAKSKKI PLGG
    """,
    "testdisc" :
    """     3    10
CAM        0000000000 
TERP       0000011111 
BM3        0001111111 
    """,
    "testrest" :
    """   5   13   2
Alpha     ++-+-++--+++-
Beta      ++++--+--+++-
Gamma     -+--+-++-+-++
Delta     ++-+----++---
Epsilon   ++++----++---

    """,
    "testdist" :
    """    7
Bovine      0.0000  1.2385  1.3472  1.2070  1.0857  1.2832  1.2402
Mouse       1.2385  0.0000  1.1231  1.0966  1.1470  1.2157  1.1530
Gibbon      1.3472  1.1231  0.0000  0.5924  0.5077  0.5466  0.5001
Orang       1.2070  1.0966  0.5924  0.0000  0.3857  0.4405  0.4092
Gorilla     1.0857  1.1470  0.5077  0.3857  0.0000  0.3170  0.2817
Chimp       1.2832  1.2157  0.5466  0.4405  0.3170  0.0000  0.2570
Human       1.2402  1.1530  0.5001  0.4092  0.2817  0.2570  0.0000
    """,
    "testtree" :
   "((BM3,TERP),CAM);"
    }
     
if __name__ == "__main__":
    print("Starting main")
    main()
else:
    print("fuck")
