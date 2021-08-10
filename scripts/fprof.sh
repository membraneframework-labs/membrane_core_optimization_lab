#!/bin/bash

save_dir="profile/fprof"

fprof () {
    local branch=$1
    local prefix=$2

    echo "Running fprof using membrane_core '$branch' for 10s"

    ( cd ../membrane_core && git checkout $branch ) \
        && mix deps.compile membrane_core \
        && MIX_ENV=prod elixir --erl "+sbwt none" -S mix fprof \
            | sed -u '/^Done\!.*/,$!d' \
            | tail -n +3 \
            | tee -a ${save_dir}/${prefix}_${branch#"tags/"}.txt
}

init_branch=$( cd ../membrane_core && git rev-parse --abbrev-ref HEAD )
mkdir -p $save_dir
now=$(date +"%d%m_%H%M%S")

fprof "tags/v0.7.0" $now

for branch in "$@"
do
    fprof $branch $now
done

( cd ../membrane_core && git checkout $init_branch )