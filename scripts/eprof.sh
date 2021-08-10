#!/bin/bash

save_dir="profile/eprof"

eprof () {
    local branch=$1
    local prefix=$2

    echo "Running eprof using membrane_core '$branch' for 10s"

    ( cd ../membrane_core && git checkout $branch ) \
        && mix deps.compile membrane_core \
        && MIX_ENV=prod elixir --erl "+sbwt none" -S mix eprof \
            | sed -u '/^Profile.*/,$!d' \
            | tee -a ${save_dir}/${prefix}_${branch#"tags/"}.txt
}

init_branch=$( cd ../membrane_core && git rev-parse --abbrev-ref HEAD )
mkdir -p $save_dir
now=$(date +"%d%m_%H%M%S")

eprof "tags/v0.7.0" $now

for branch in "$@"
do
    eprof $branch $now
done

( cd ../membrane_core && git checkout $init_branch )