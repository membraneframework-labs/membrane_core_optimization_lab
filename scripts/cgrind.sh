#!/bin/bash

save_dir="profile/cgrind"

cgrind () {
    local branch=$1
    local prefix=$2

    echo "Running cgrind using membrane_core '$branch' for 10s"

    ( cd ../membrane_core && git checkout $branch ) \
        && mix deps.compile membrane_core \
        && MIX_ENV=prod elixir --erl "+sbwt none" -S mix cgrind \
        && ./scripts/erlgrind fprof.trace ${save_dir}/${prefix}_${branch#"tags/"}.cgrind
}

init_branch=$( cd ../membrane_core && git rev-parse --abbrev-ref HEAD )
mkdir -p $save_dir
now=$(date +"%d%m_%H%M%S")

cgrind "tags/v0.7.0" $now

for branch in "$@"
do
    cgrind $branch $now
done

rm fprof.analysis fprof.trace

( cd ../membrane_core && git checkout $init_branch )