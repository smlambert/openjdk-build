#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
# #
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eu

echo "WORKSPACE: $WORKSPACE"

tagName=$(hg tags | grep jcov | head -1 | awk '{ print $1 }')
echo "Tag:" ${tagName}

hg checkout "${tagName}"

fileName=build/_release.properties;

cat build/release.properties | sed 's/\d./d_/g' > $fileName 

buildVersion=`cat $fileName | grep build_version |  cut -d'=' -f2 | cut -d' ' -f2 | tr -d '\r'`
buildNumber=`cat $fileName | grep build_number |  cut -d'=' -f2 | cut -d' ' -f2 | tr -d '\r'`
buildMilestone=`cat $fileName | grep build_milestone |  cut -d'=' -f2 | cut -d' ' -f2 | cut -d'.' -f2 | tr -d '\r'`

if [ ! -d jtharness ]; then
   wget http://download.java.net/jtharness/4.4.1/Rel/jtharness-4_4_1-MR1-bin-b13-20_dec_2011.zip
   mkdir jtharness
   cd jtharness
   unzip -o ../jtharness-4_4_1-MR1-bin-b13-20_dec_2011.zip
   cd ..
fi

if [ ! -d asm-6.0 ]; then
   wget http://download.forge.ow2.org/asm/asm-6.0-bin.zip
   unzip -o asm-6.0-bin.zip
fi

ls -lash

cd build

echo "${buildVersion} ${buildNumber} ${buildMilestone}"

ant clean
ant -v build -f build.xml -Dasm.jar=${WORKSPACE}/asm-6.0/lib/asm-6.0.jar -Dasm.tree.jar=${WORKSPACE}/asm-6.0/lib/asm-tree-6.0.jar -Dasm.util.jar=${WORKSPACE}/asm-6.0/lib/asm-util-6.0.jar -Djavatestjar=${WORKSPACE}/jtharness/lib/javatest.jar
cd ..

rm -f *.zip
rm -f *.tar.gz

pwd

ls -lash

artifact=jcov-${buildVersion}-${buildMilestone}-${buildNumber}

rm -fr JCOV_BUILD/temp

tar fcv $artifact.tar JCOV_BUILD
gzip -9 ${artifact}.tar

echo "Creating checksum for artifact ${artifact}"
sha256sum ${artifact}.tar.gz > ${artifact}.tar.gz.sha256sum.txt

echo "Finished creating artifact: ${artifact}"
