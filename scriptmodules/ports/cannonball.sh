#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="cannonball"
rp_module_desc="Cannonball - An Enhanced OutRun Engine"
rp_module_menus="4+"

function depends_cannonball() {
    getDepends cmake libsdl2-dev libboost-dev
}

function sources_cannonball() {
    gitPullOrClone "$md_build" https://github.com/djyt/cannonball.git
    sed -i "s/-march=armv6 -mfpu=vfp -mfloat-abi=hard//" $md_build/cmake/sdl2_rpi.cmake $md_build/cmake/sdl2gles_rpi.cmake
}

function build_cannonball() {
    local target
    mkdir build
    cd build
    if isPlatform "rpi"; then
        target="sdl2gles_rpi"
    elif isPlatform "mali"; then
        target="sdl2gles"
    else
        target="sdl2gl"
    fi
    cmake -G "Unix Makefiles" -DTARGET=$target ../cmake/
    make clean
    make
    md_ret_require="$md_build/build/cannonball"
}

function install_cannonball() {
    md_ret_files=(
        'build/cannonball'
        'roms/roms.txt'
    )

    mkdir -p "$md_inst/res"
    cp -v res/*.bin "$md_inst/res/"
    cp -v res/config_sdl2.xml "$md_inst/config.xml.def"
}

function configure_cannonball() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
    mkUserDir "$configdir/$md_id"

    moveConfigFile "config.xml" "$configdir/$md_id/config.xml"
    moveConfigFile "hiscores.xml" "$configdir/$md_id/hiscores.xml"

    if [[ ! -f "$configdir/$md_id/config.xml" ]]; then
        cp -v "$md_inst/config.xml.def" "$configdir/$md_id/config.xml"
    fi

    cp -v roms.txt "$romdir/ports/$md_id/"

    chown -R $user:$user "$romdir/ports/$md_id" "$configdir/$md_id"

    ln -snf "$romdir/ports/$md_id" "$md_inst/roms"

    addPort "$md_id" "cannonball" "Cannonball - OutRun Engine" "pushd $md_inst; $md_inst/cannonball; popd"

    __INFMSGS+=("You need to unzip your OutRun set B from latest MAME (outrun.zip) to $romdir/ports/$md_id. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work.")
}