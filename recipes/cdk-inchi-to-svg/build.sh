#!/bin/bash
cd cdk-inchi-to-svg 
mvn package 
for i in $(find . -name "*with-dependencies*jar"); do install -m755 "$i" ${PREFIX}/bin/cdk-inchi-to-svg.jar; done
echo "#!/bin/bash" > ${PREFIX}/bin/start-cdk-inchi-to-svg.sh
echo "java -jar \`which cdk-inchi-to-svg.jar\` \"\$@\"" >> ${PREFIX}/bin/start-cdk-inchi-to-svg.sh
chmod +x ${PREFIX}/bin/start-cdk-inchi-to-svg.sh