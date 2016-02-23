#!/bin/sh

nubuild_repo_url=https://github.com/Microsoft/Ironclad
nubuild_repo_branch=nubuild
nuget_url=https://api.nuget.org/downloads/nuget.exe

self=$(basename $0)

if [ "x$VS_ENV" == "x" ]; then
   >&2 echo "$self: Detecting newest Visual Studio installation."
   VS_ENV=$(set |grep -e VS[0-9][0-9][0-9]COMNTOOLS | cut -d = -s -f-1 - | sort | tail -n 1)
   if [ "x$VS_ENV" == "x" ]; then
      >&2 echo "$self: FAIL! Visual Studio does not appear to be installed."
      exit 1
   fi
fi

mitls_prefix=$(git rev-parse --show-toplevel)
exit=$?
if [ $exit -ne 0 ]; then
  exit $exit
fi

nubuild_prefix=$mitls_prefix/.nubuild
if [ ! -d $nubuild_prefix ]; then
   >&2 echo "$self: .nubuild directory not found; attempting to install."
   cd $mitls_prefix && git clone -b $nubuild_repo_branch --single-branch $nubuild_repo_url .nubuild
else
   >&2 echo "$self: .nubuild directory found; attempting to update."
   cd $nubuild_prefix && git pull
fi

>&2 echo "$self: Restoring NuGet package cache..."
nuget=$nubuild_prefix/bin/nuget.exe
if [ -x $nuget ]; then
   curl -s $nuget_url -z $nuget -o $nuget
else
   mkdir -p $(dirname $nuget)
   curl -s $nuget_url -o $nuget
fi
cd $nubuild_prefix/src && $nuget restore NuBuild.sln

>&2 echo "$self: Building NuBuild..."
cd $nubuild_prefix/src && $mitls_prefix/scripts/build-nubuild.bat $VS_ENV

nubuild_config=$nubuild_prefix/config.json
if [ ! -e $nubuild_config ]; then
   >&2 echo "$self: IMPORTANT! You will need to create a \`.nubuild/config.json\` file in order to use NuBuild. See \`docs/examples/config.json\` for an example." 
elif ! grep -q storage $nubuild_config ; then
   >&2 echo "$self: IMPORTANT! Your \`.nubuild/config.json\` file lacks Azure Storage credentials. Distributed cache will not function without them." 
fi

