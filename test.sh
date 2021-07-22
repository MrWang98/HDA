#!/bin/bash
rawroot="raw_data/data"
matroot="radar_script/mat_data"
txtroot="data/DATA"

matlab_code="radar_script/processer2.py"
python_code=""
test_path=("test")

submit_matlab(){
  #尝试提交任务，最多尝试20次，成功后将flag置1
  flag=0
  count=0
  while [ ${count} -lt 20 ]
  do
    count=`expr ${count} + 1`
    sbatch matlab.slurm ${1} ${2}
    if [ $? -eq 0 ]
    then
      flag=1
      break
    fi
  done

  #显示是否成功提交任务
  if [ ${flag} -eq 0 ]
  then
    echo "matlab: ${1} ${2} submit failed"
  fi
}

submit_python(){
  #尝试提交任务，最多尝试20次，成功后将flag置1
  flag=0
  count=0
  while [ ${count} -lt 20 ]
  do
    count=`expr ${count} + 1`
    sbatch slurm.slurm ${1} ${2} ${3}
    if [ $? -eq 0 ]
    then
      flag=1
      break
    fi
  done

  #显示是否成功提交任务
  if [ ${flag} -eq 0 ]
  then
    echo "python: ${1} ${2} submit failed"
  fi
}

dirs=`ls ${rawroot}`
#dirs=(chengcongxiao)

for dir in ${dirs[@]}
do
  echo ${dir}
  if [ ! -d "error/${dir}" ]
  then
    mkdir "error/${dir}"
  fi
  #获得原始数据列表
  rawkinds=()
  files=`ls ${rawroot}/${dir}`
  for kind in ${files[@]}
  do
    if [ ${kind} != "breath" ]
    then
      rawkinds+=(${kind})
    fi
  done
#  echo "rawkinds:${rawkinds[@]}"

  if [ ! -d "${matroot}/${dir}" ]
  then
    for kind in ${rawkinds[@]}
    do
      echo "run ${dir} ${kind} matlab"
      submit_matlab ${dir} ${kind}
    done
  fi

  #获得matlab已处理的列表
  matkinds=()
  files=`ls ${matroot}/${dir}`
  for kind in ${files[@]}
  do
    images=`ls ${matroot}/${dir}/${kind}/wet`
#    matkinds+=(${kind})

    count=0
    for i in ${images[@]}
    do
      count=`expr ${count} + 1`
    done
    if [ ${count} -gt 639 ]
    then
      matkinds+=(${kind})
    fi
  done
#  echo "matkinds:${matkinds[@]}"

  #比较以上两个列表获得未经过matlab处理的列表
  diff_list=()
  t=0
  flag=0
  for rawkind in "${rawkinds[@]}"
  do
      for matkind in "${matkinds[@]}"
      do
          if [[ "${rawkind}" == "${matkind}" ]]; then
              flag=1
              break
          fi
      done
      if [[ $flag -eq 0 ]]; then
          diff_list[t]=${rawkind}
          t=$((t+1))
      else
          flag=0
      fi
  done
  echo raw-mat-diff=${diff_list[@]}

  #调用matlab处理程序
  for kind in ${diff_list[@]}
  do
    echo "run ${dir} ${kind} matlab"
    submit_matlab ${dir} ${kind}
  done

  #获得txt文件列表
  txtkinds=()
  files=`ls ${txtroot}/${dir}`
  for file in ${files[@]}
  do
    t=`echo "${file//.txt/}"`
    t=`echo "${t}" | tr '_' ' '`
    for temp in ${t[@]}
    do
      txtkinds+=(${temp})
      break
    done
  done
  # 去重
  txtkinds=($(awk -v RS=' ' '!a[$1]++' <<< ${txtkinds[@]}))
#  echo "去重后:"${txtkinds[@]}

  #比较以上两个列表获得未写到的txt文件
  diff_list=()
  t=0
  flag=0
  for matkind in "${matkinds[@]}"
  do
      for txtkind in "${txtkinds[@]}"
      do
          if [[ "${matkind}" == "${txtkind}" ]]; then
              flag=1
              break
          fi
      done
      if [[ $flag -eq 0 ]]; then
          diff_list[t]=${matkind}
          t=$((t+1))
      else
          flag=0
      fi
  done
  echo mat-txt-diff=${diff_list[@]}

  #调用matlab处理程序
  for kind in ${diff_list[@]}
  do
    echo "write ${dir} ${kind} txt"
  done

  #运行对应python程序
  for kind in ${txtkinds[@]}
  do
    txt_file="result/${dir}/${kind}.txt"
    log_file="result/${dir}/${kind}.log"

    if [ -e ${txt_file} ]
    then
      txt_size=`wc -c < ${txt_file}`
      if [ $((txt_size)) -eq 0 ]
      then
        echo "txt is 0"
        echo "run ${dir} ${kind} python"
#        submit_python ${dir} ${kind} 0
      fi
    elif [ -e ${log_file} ]
    then
      log_size=`wc -c < ${log_file}`
      if [ $((log_size)) -eq 0 ]
      then
        echo "log is 0"
        echo "run ${dir} ${kind} python"
#        submit_python ${dir} ${kind} 0
      fi
    else
      echo "run ${dir} ${kind} python"
#      submit_python ${dir} ${kind} 0
    fi

  done
#  break

done

