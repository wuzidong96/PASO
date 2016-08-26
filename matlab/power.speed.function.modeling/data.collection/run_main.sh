for zz in neg_0 neg_1 neg_2 neg_3 neg_4 neg_5 neg_6 neg_7 neg_8 neg_9 pos_0 pos_1 pos_2 pos_3 pos_4 pos_5 pos_6 pos_7 pos_8 pos_9
do
    echo ${zz}
    matlab < main_grade_${zz}.m &> ${zz}_${HOSTNAME}.log &
done
    
