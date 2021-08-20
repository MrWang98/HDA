matroot="radar_script/mat_data"
dirs=`ls ${matroot}`
for dir in ${dirs[@]}
do
  files=`ls ${matroot}/${dir}`
  for kind in ${files[@]}
  do
    if [ -d "${matroot}/${dir}/${kind}/wet" ];then
      images=`ls ${matroot}/${dir}/${kind}/wet`
    #    matkinds+=(${kind})

      count=0
      for i in ${images[@]}
      do
        count=`expr ${count} + 1`
      done
      if [ ${count} -lt 640 ]
      then
        echo "${matroot}/${dir}/${kind}"
      fi
    else
      echo "${matroot}/${dir}/${kind}"
    fi
  done
done