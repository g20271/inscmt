#!/bin/bash
#v1.1
install_path="${HOME}/.local/share/inscmt/inscmt.sh"
file=${install_path##*/}
file=${file%%.*}

echo "inscmtを'$install_path'にインストールします
インストールしようとしているバージョン: v1.1"

if [ -e $install_path ]; then
    echo -e "\n既にインストールされていますが置き換えますか? \
    \n現在インストールされているバージョン: $(cat $install_path | sed -n 2p | sed 's/#//' )"
    read -p "(Y/n): " chk
    case $chk in
        "Y" | "y" | "Yes" | "yes" | "" ) echo "置き換えます" ;;
        * ) echo -e "キャンセルしました" && exit ;;
    esac
else
    echo "インストールしますか?"
    read -p "(Y/n): " chk
    case $chk in
        "Y" | "y" | "Yes" | "yes" | "" ) echo "インストールします" ;;
        * ) echo -e "キャンセルしました" && exit ;;
    esac
fi

mkdir -p ${install_path%/*}


echo -e "\nあなたの出席番号を入力してください"
read -p "Number: " number
echo "あなたの名前を入力してください"
read -p "Name: " name


sed -e "0,/number=/ s/number=/number=$number/" -e "0,/name=\"\"/ s/name=\"\"/name=\"$name\"/" << 'EOS' > $install_path
#!/bin/bash
#v1.1
#このシェルスクリプトは2020/05/20のutil-linux 2.35の仕様変更に対応しています
#最新のLinux環境と演習室のCentOS 7を判定します

number=        #自分の出席番号を入力
name=""  #自分の名前を入力



util_linux_version=$(script --version); util_linux_version=${util_linux_version##* }
termcol=$(tput cols)

if [ $# = 0 ]; then
    echo -e "Error! 引数が必要です \
    \nファイル名を記述してください \
    \n例: \
    \ninscmt r1-1.c                #'r1-1.c'を指定 \
    \ninscmt k1-1.c k1-2.c k1-3.c  #'k1-1.c' 'k1-2.c' 'k1-3.c'を指定 \
    \ninscmt *.c                   #ファイル名の最後が'.c'のものをすべて指定 \
    \ninscmt k1-*.c                #ファイル名の最初が'k1-'かつ \
    \n                              最後に'.c'がつくものをすべて指定 \
    \n \
    \nヒント: '*'はワイルドカードというシェル標準の機能です \
    \n他の詳しいシェル展開機能についてはググってください \
    \n \
    \ninscmt v1.1 made by g20271 \
    \n \
    \nこのシェルスクリプトは2020/05/20のutil-linux 2.35の仕様変更に対応しています \
    \n最新のLinux環境と演習室のCentOS 7を判定します \
    \n \
    \nutil-linuxのバージョンは $util_linux_version で $(echo $util_linux_version | awk -F. '{printf "%2d%02d%02d", $1,$2,$3}') と変換しました"

    if [ $(echo $util_linux_version | awk -F. '{printf "%2d%02d%02d", $1,$2,$3}') -ge 23500 ]; then #util-linux --version >= 2.35
        echo "判定結果: 最新Linux環境モードで実行します(演習室で動作しません)"
    else
        echo "判定結果: 演習室用旧Linux互換モードで実行します(最新Linux環境で動作しません)"
    fi
fi

function category_choose() {
    echo -e "\nファイル名にrが入っています \
    \nどちらのカテゴリか数字を入力して選択してください \
    \n[1] レポート \
    \n[2] 課題集例題"
    read -p "Please Type The Number: " rtype

    case $rtype in
        1 | １ ) category="レポート"   ;;
        2 | ２ ) category="課題集例題" ;;
        * ) echo "Error! 対応した数字を入力してください。" && category_choose ;;
    esac
}

function save_confirm() {
    echo -e "\n作成したファイルに問題がない場合のみ保存してください"
    read -p "上書き保存しますか? (Y/n): " chk

    case $chk in
        "Y" | "y" | "Yes" | "yes" | "" ) \cp -f /tmp/patchedfile $file && echo -e "保存しました\n" ;;
        "N" | "n" | "No"  | "no"  ) echo -e "キャンセルしました\n" ;;
        * ) echo -e "正しい文字を入力してください\n" && save_confirm ;;
    esac
}


for file in $*; do
    if [ ! -e $file ]; then
        echo -e "Error! \
        \n$file が見つかりませんでした \
        \n入力ミスやパスが正しいか確認してください"
        continue
    fi

    filename=${file##*/}
    echo "入力されたファイル: $filename"

    if [ ${filename##*.} != "c" ]; then
        echo -e "Error! 拡張子が '.c' ではありません \
        \n入力されたファイルは本当に正しいですか?"
        continue
    fi

    category=${filename:0:1}
    if   [ $category = "r" ]; then
        category_choose
    elif [ $category = "k" ]; then category="課題集課題"
    elif [ $category = "c" ]; then category="挑戦的課題"
    else
        echo -e "Error! $filename のファイル名からカテゴリを取得できませんでした \
        \nファイル名の命名規則が遵守されているか確認してください"
        continue
    fi

    syou=${filename:1}
    syou=${syou%%-*}

    bangou=${filename##*-}
    bangou=${bangou%%.*}

    echo -e "\nファイル名:$filename カテゴリ:$category 章:$syou 課題:$bangou"


    gcc -o a.out $file -lm

    echo -e "\n$filename を実行します 例として提出したい標準入力を行ってください\n"

    printf -- "-%.0s" {1..10} && echo -n "< $filename >" && printf -- "-%.0s" {1..10} && echo

    if [ $(echo $util_linux_version | awk -F. '{printf "%2d%02d%02d", $1,$2,$3}') -ge 23500 ]; then #util-linux --version >= 2.35
        script /tmp/out -c ./a.out -q

        cat /tmp/out | sed ':a;s/[^\x08]\x08//g;ta' | sed -r "s/[\x1b]\[K|\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g" | col -b |\
        sed -e '1d' -e '$d' | sed '${/^$/d;}' | sed -e '1s/^/\n/'| sed -e '2i \/*' -e '$ a *\/' > /tmp/aout


        echo && eval printf -- '-%.0s' {1..$((${#filename}+24))}
    else
        script /tmp/out -c 'echo && ./a.out' -q

        cat /tmp/out | sed ':a;s/[^\x08]\x08//g;ta' | sed -r "s/[\x1b]\[K|\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g" | col -b |\
        sed -e '1d' -e '2d' | sed '${/^$/d;}' | sed -e '1s/^/\n/'| sed -e '2i \/*' -e '$ a *\/' > /tmp/aout


        echo && eval printf -- '-%.0s' {1..$((${#filename}+24))}
    fi

    echo -e "\n$filename が終了しました"

    \cp -f $file /tmp/patchedfile
    sed -i "1i\/*$number $name" /tmp/patchedfile
    sed -i "2i 「第$syou回$category $bangou」*\/" /tmp/patchedfile
    cat /tmp/aout >> /tmp/patchedfile

    echo -e "挿入済みファイルの生成が完了しました \
    \nVimで開くので出来上がったファイルに問題がないか確認し修正してください(:qで終了)"
    read -p "Please Hit Enter Key: "
    vim /tmp/patchedfile

    save_confirm
done
EOS

chmod 711 $install_path

if ! grep -q ".bashrc" ~/.bash_profile; then
    touch ~/.bash_profile
    echo 'source ~/.bashrc' >> ~/.bash_profile
fi

if ! grep -q "alias $file=$install_path" ~/.bashrc; then
    touch ~/.bashrc
    echo "alias $file=$install_path" >> ~/.bashrc
fi

alias $file=$install_path


echo "インストールが完了しました"
