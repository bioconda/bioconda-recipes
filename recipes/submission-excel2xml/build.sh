#! /bin/bash

gem install open3 -v "0.1.2"
gem install mini_portile2 -v "2.4.0"
gem install nokogiri -v "1.15.3"
gem install rubyzip -v "2.3.2"
gem install roo -v "2.10.0"
gem install builder -v "3.2.4"
gem install date -v "3.0.0"
gem install rexml -v "3.2.5"

APPROOT=$PREFIX/opt/submission-excel2xml


mkdir -p $APPROOT


cp excel2xml_dra.rb $PREFIX/bin
cp validate_meta_dra.rb $PREFIX/bin
cp excel2xml_jga.rb $PREFIX/bin
cp validate_meta_jga.rb $PREFIX/bin

chmod a+x $PREFIX/bin/excel2xml_dra.rb
chmod a+x $PREFIX/bin/validate_meta_dra.rb
chmod a+x $PREFIX/bin/excel2xml_jga.rb
chmod a+x $PREFIX/bin/validate_meta_jga.rb

cd $APPROOT

curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.analysis.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.annotation.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.common.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.experiment.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.package.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.run.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.sample.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.study.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/dra/xsd/1-5/SRA.submission.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.analysis.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.common.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.dac.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.data.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.dataset.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.experiment.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.policy.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.sample.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.study.xsd
curl -LO https://raw.githubusercontent.com/ddbj/pub/master/docs/jga/xsd/1-2/JGA.submission.xsd

