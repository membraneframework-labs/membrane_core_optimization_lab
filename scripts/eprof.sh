#!/bin/bash

save_dir="profile/eprof"

eprof () {
    local branch=$1
    local time=$2
    local prefix=$3

    echo "Running eprof using membrane_core branch '$branch' for $time s"

    ( cd ../membrane_core && git checkout $branch ) \
        && MIX_ENV=prod elixir --erl "+sbwt none" -S mix eprof $time \
            | sed -u '/^Profile.*/,$!d' \
            | tee -a ${save_dir}/${prefix}_${branch}_${time}.txt
}

time=${TIME:-10}
now=$(date +"%d%m_%H%M%S")

mkdir -p $save_dir

eprof "master" $time $now

for branch in "$@"
do
    eprof $branch $time $now
done