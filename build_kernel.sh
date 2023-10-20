#/bin/bash
set -e
source "./local.config"

[ ! -e "scripts/packaging/pack.sh" ] && git submodule init && git submodule update
[ ! -e "toolchain" ] && echo "Make toolchain avaliable at $(pwd)/toolchain" && exit

function tg_sendText() {
        curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
                -d "parse_mode=html" \
                -d text="${1}" \
                -d chat_id=$CHAT_ID \
                -d "disable_web_page_preview=true"
}

tg_sendText "Build started!"

# Patch for 4.14
sed -i 's/#ifdef CONFIG_KPROBES/#if 0/g' KernelSU/kernel/ksu.c

export KBUILD_BUILD_USER=shadow
export KBUILD_BUILD_HOST=elite

PATH=$PWD/toolchain/bin:$PATH

rm -rf out
make O=out CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 -j$(nproc) vendor/nh_defconfig
toilet -f future --filter border:metal BUILD START | lolcat
make O=out CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 -j$(nproc) 2>&1 | tee ./out/build.log

echo "\n" && toilet -f future --filter border:metal BUILD END | lolcat
