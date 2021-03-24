#!/bin/bash

set -eu

# $1: リクエストするURL
# $2: リクエストする回数
# $3: リクエストする間隔
function main() {
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


# リクエスト回数のデフォルト値
n_times=1

# リクエストする間隔のデフォルト値
interval_sec=2


# オプションの処理を行う
# TODO: ファイルを読み込んでリクエストを可能にする
while getopts "n:i:" option
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
    \?)
      echo "Usage: curl.sh [-n request_tmes] [-i request_interval(sec)] target_url" 1>&2
      exit 1
      ;;
  esac
done

# オプション指定を位置パラメータから削除する
shift $(expr ${OPTIND} - 1)

# urlを変数に格納する
url=$1

main ${url} ${n_times} ${interval_sec}

exit 0
