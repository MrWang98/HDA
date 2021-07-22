dirs=`ls error`
for dir in ${dirs[@]}
do
  files=`ls error/${dir}`
  for file in ${files[@]}
  do
    file_size=`wc -c < error/${dir}/${file}`
    echo "size:${file_size}   error/${dir}/${file}"
  done
done

echo -e "\n"

#dirs=`ls radar_script/mat_data`
#for dir in ${dirs[@]}
#do
#  kinds=`ls radar_script/mat_data/${dir}`
#  for kind in ${kinds[@]}
#  do
#    echo "radar_script/mat_data/${dir}/${kind}"
#  done
#done