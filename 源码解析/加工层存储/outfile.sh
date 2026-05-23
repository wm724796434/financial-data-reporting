bin/bash
source /home/ldmdata/.bash_profile

#本脚本用来将指定数据库接口表数据抽取通过交互服务器下发数据湖。
#sh outfile.sh PBOCD 20250630

#入参1 ($1): 必输参数，表示系统英文简称
sys_name=$1
#入参2 ($2): 必输参数，表示数据日期（格式为 yyyyMMdd）
data_date=$2
#入参3 ($3): 非必输参数，表示文件名。如果提供，则生成指定文件；否则，按配置表生成文件。
file_name=$3

data_date1=$(echo $2 | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/')
echo $data_date1

# 设置配置文件路径
CONFIG_FILE="/home/ldmdata/LDM_IMP/outfile/db_config.cfg"

# 从配置表中获取数据库连接信息
read -r ORACLE_SID ORACLE_USER ORACLE_PASSWORD <<< $(awk -F' ' '$1 == "'${sys_name}'" {print $2, $3, $4}' db_config.cfg)

if [ -z "$ORACLE_SID" ] || [ -z "$ORACLE_USER" ] || [ -z "$ORACLE_PASSWORD" ]; then
    echo "未找到系统 $sys_name 的数据库连接信息，请检查配置表。"
    exit 1
fi

# 设置交互服务器连接信息
# 测试
#REMOVE_DIR=/dsbdata/ods_data_up/RSBP
#SSH_USER=rsbp
#SSH_PWD=rsbp
#HOST=25.13.12.20

# 生产
REMOVE_DIR=/dsbdata/ods_data_up/RSBP
SSH_USER=rsbp
SSH_PWD=rsbp
HOST=214.6.13.129

# 设置输出文件路径
OUTPUT_DIR="/home/ldmdata/LDM_IMP/outfile/dat_tmp"

# 创建路径
if [ -d ${OUTPUT_DIR}/${sys_name} ]; then
	echo "${OUTPUT_DIR}/${sys_name}"
	echo "${sys_name}当期路径存在，无需创建" 
else
	echo "创建临时文件路径 ${sys_name}" 
	cd ${OUTPUT_DIR}
	mkdir ${sys_name}
fi

export NLS_LANG=AMERICAN_AMERICA.UTF8
export LANG=en_US.UTF-8

# SFTP传输函数
sftp_transfer() {
local local_file=$1
local remote_file=$2
set timeout 30
expect <<EOF
spawn sftp -oStrictHostKeyChecking=no ${SSH_USER}@${HOST}
expect "password:"
send "${SSH_PWD}\r"
expect "sftp>"
send "put ${local_file} ${REMOVE_DIR}/${remote_file}\r"
expect "sftp>"
send "exit\r"
EOF
}

# 按行读取tablelist_pboc.cfg文件，并按空格拆分
while IFS=' ' read -r query_key table_name column_list
do
    echo "查询条件: ${query_key}, 表名: ${table_name}, 列名: ${column_list}"

 if [ -n "${file_name}" ] && [ "${file_name}" != "${table_name}" ]; then
        echo "跳过表名: ${table_name}"
        continue
    fi

OUTPUT_FILE1=RSBP_${sys_name}_${table_name}_${data_date}.dat

sqlplus -S /nolog <<EOF
connect ${ORACLE_USER}/${ORACLE_PASSWORD}@${ORACLE_SID}
set colsep '&'
set echo off
set feedback off
set heading off
set trimout on
set pagesize 0
set linesize 1000
set trimspool on
set termout off
set serveroutput off


spool ${OUTPUT_DIR}/${sys_name}/temp_file1.dat
SELECT ${column_list} FROM ${table_name} where REPLACE(${query_key},'-') = TO_CHAR(TO_DATE('${data_date}','yyyymmdd')-30,'yyyymmdd');

spool off

exit
EOF

# 使用awk命令将分隔符 & 转换为0x02
# 遍历dat文件中的每一个字段，如果不是最后一个字段，则将字段和二进制分隔符一起输出，否则只输出字段值并在末行添加分隔符

awk 'BEGIN{FS="&";OFS=ORS=""}{for(i=1;i<=NF;i++) {if(i!=NF) printf "%s\x02",$i; else printf "%s\n",$i}}' ${OUTPUT_DIR}/${sys_name}/temp_file1.dat > ${OUTPUT_DIR}/${sys_name}/temp_file2.dat
rm -rf ${OUTPUT_DIR}/${sys_name}/temp_file1.dat
mv ${OUTPUT_DIR}/${sys_name}/temp_file2.dat ${OUTPUT_DIR}/${sys_name}/${OUTPUT_FILE1}

echo "导出完成！文件：${OUTPUT_DIR}/${sys_name}/${OUTPUT_FILE1}"

##将生成的.dat文件传输到交互平台指定位置
#ftp -v -n ${HOST}<<EOF
#user rsbp rsbp
#
#put ${OUTPUT_DIR}/${sys_name}/${OUTPUT_FILE1} ${REMOVE_DIR}/${OUTPUT_FILE1}
#
#exit
#
#EOF

# SFTP传输数据文件
    sftp_transfer "${OUTPUT_DIR}/${sys_name}/${OUTPUT_FILE1}" "${OUTPUT_FILE1}"

done < ${OUTPUT_DIR}/../tablelist_cfg/${sys_name}.cfg

# 延时60秒之后下发ok文件
for i in $(seq 60 -1 1); do
    echo "倒计时$i秒后继续执行"
    sleep 1
done

#文件全部传输完成之后生成一个ok文件传输到交互平台指定位置
echo -e "label:RSBP_${sys_name}\nodate:${data_date1}" > ${OUTPUT_DIR}/${sys_name}/RSBP_${sys_name}_${data_date}.ok

#ftp -v -n ${HOST}<<EOF
#user rsbp rsbp
#
#put ${OUTPUT_DIR}/${sys_name}/RSBP_${sys_name}_${data_date}.ok ${REMOVE_DIR}/RSBP_${sys_name}_${data_date}.ok
#
#exit
#
#EOF

# SFTP传输数据文件
sftp_transfer "${OUTPUT_DIR}/${sys_name}/RSBP_${sys_name}_${data_date}.ok" "RSBP_${sys_name}_${data_date}.ok"

# 清理当前日期以外的文件
find ${OUTPUT_DIR}/${sys_name} -type f | while read file; do
    # 检查文件名是否包含指定字符串
    if ! echo "${file}" | grep -q "${data_date}"; then
        echo "清理临时文件: ${file}"
        rm -f "${file}"
    fi
done

echo "${sys_name}系统数据日期为${data_date}的.dat .ok文件已传输到交互平台指定位置"

echo 0

exit 
