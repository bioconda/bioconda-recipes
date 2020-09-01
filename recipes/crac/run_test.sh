EXPECTED="test/test.fasta.cluster"
#basic execution test
./CRAC -i test/test.fasta
if [ -f "$EXPECTED" ]
then
  exit 0
else
  exit 1
fi