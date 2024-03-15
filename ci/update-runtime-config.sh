#!/bin/bash

set -eu

releases=$(ls releases)

pushd releases
  for release in ${releases}; do
    pushd ${release}
      tar xf *.tgz
      release=$(grep "^name" release.MF | awk '{print $2}')
      version=$(grep "^version" release.MF | awk '{print $2}' | sed -e "s/['\"']//g")
      declare -x "runtime_release_${release//-/_}"=${version}
    popd
  done
popd

bosh -n update-runtime-config \
  bosh-config/runtime-config/runtime.yml \
  --vars-env runtime \
  --var=bosh_environment=${BOSH_ENV_NAME} \
  --vars-file terraform-yaml/state.yml


bosh -n update-runtime-config --name dns \
  bosh-deployment/runtime-configs/dns.yml \
  --ops-file bosh-config/operations/dns-aliases.yml
