#!/usr/bin/env bash
set -e

function fullfile {
    echo $(cd $(dirname $1) && pwd)/$(basename $1)
}

function pushjar {
    if [ $# -lt 4 ]; then
        echo "usage: $0 <file> <groupId> <artifactId> <version>"
        return 1
    fi
    mvn deploy:deploy-file -Dfile=$(fullfile $1) \
        -DrepositoryId=tamr-nexus \
        -Durl=https://nexus.tamrdev.com:8091/nexus/content/repositories/thirdparty/ \
        -DgroupId=$2 -DartifactId=$3 -Dversion=$4 $5
    find ~/.gradle -name '*.jar' | grep $(basename $1) | xargs -t -n 1 rm -rf
}

basedir=$(cd $(dirname $0) && pwd)
version=0.5
$basedir/gradlew build :scheduler:copyJar -x test
pushjar $basedir/scheduler/build/docker/mesos-elasticsearch-scheduler.jar \
        org.apache.mesos \
        mesos-elasticsearch-scheduler \
        1.0.1-tamr-${version}
