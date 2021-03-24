#!/bin/bash

set -eu

# URL,回数,間隔を指定してリクエストを行う
# $1: リクエストするURL
# $2: リクエストする回数
# $3: リクエストする間隔
function curl_ntimes() {
  local url=$1
  local times=$2
  local interval_sec=$3

  echo "interval: ${interval_sec} sec"

  for i in $(seq 1 ${times})
  do
    echo "${i}: ${url}"
    curl -XGET ${url} > result-${i}.json
    sleep ${interval_sec}
  done
}

# ファイルからURLのリストを読み込んで、リクエストを連続して行う
# $1: 読み込みファイル名
# $2: リクエストする間隔
function curl_by_file() {
  local filename=$1
  local interval_sec=$2
  local counter=0

  echo "interval: ${interval_sec} sec"

  cat ${filename} | while read url
  do
    counter=$((counter += 1))
    echo "request: ${url}"
    curl -XGET ${url} > result-${counter}.json
    sleep ${interval_sec}
  done
}


# リクエスト回数のデフォルト値
n_times=1
# リクエスト間隔のデフォルト値
interval_sec=2
# URLを読み込むファイル名
url_list_file=""
# fオプションが指定されているフラグ
f_flag=0

# オプションの処理を行う
while getopts "n:i:f:" option
do
  case ${option} in
    n)
      # -nオプションでリクエスト回数を設定できる
      n_times=${OPTARG}
      ;;
    i)
      # -iオプションでリクエスト間隔を設定できる
      interval_sec=${OPTARG}
      ;;
    f)
      # -fオプションでファイルから読み込める
      url_list_file=${OPTARG}
      # ファイルの存在チェック
      if [ -e ${url_list_file} ]; then
        f_flag=1
      else
        echo "${url_list_file}: No such file."
        exit 1
      fi
      ;;
    \?)
      echo "Usage: curl.sh [-n request_tmes] [-i request_interval(sec)] target_url" 1>&2
      echo "Usage: curl.sh [-f] file_name" 1>&2
      exit 1
      ;;
  esac
done

# オプション指定を位置パラメータから削除する
shift $(expr ${OPTIND} - 1)

if [ ${f_flag} -eq 1 ]; then
  # ファイル指定でリクエストを実行する
  curl_by_file ${url_list_file} ${interval_sec}
else
  # urlを変数に格納する
  url=$1
  curl_ntimes ${url} ${n_times} ${interval_sec}
fi

exit 0
