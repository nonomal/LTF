#!/bin/bash

## TODO : init
## In   : $1=>Log Path
RetSetup(){
	logPath=${1}
	if [ ! -d "$1" ];then
		mkdir -p $1 &>/dev/null
		# 判断是否创建失败
		if [ $? -ne 0 ];then
			return 1
		fi
	fi

	retTPASSNum=0
	retTFAILNum=0
	retTCONFNum=0
	retERRORNum=0
	retTotal=0

	# 开始界面
	RetBrkUsage
	
	return 0
}


RetBrkUsage(){
	
	printf " \n\
\t\t#       #######   ######\n \
\t\t#          #      #\n \
\t\t#          #      #####\n \
\t\t#          #      #\n \
\t\t#          #      #\n \
\t\t######     #      #\n\n"
	
	printf "%-s\n" ---------------------------------------------------------

	cat >&1 <<-EOF

Machine         : $AUTOTEST_ARCH
Hostname        : $GSI_HOSTNAME
System Version  : $GSI_SYSVER
Kernel Version  : $GSI_OSVER
Kernel Relase   : $GSI_OSREL
Runlevel        : $GSI_RUNLEVEL
Language        : $GSI_LANGUAGE
Enforce         : $GSI_ENFORCE
ShellEnv        : $GSI_SHELLENV
Test Start Time : $(date)
	EOF
	
	printf "\n"	
	printf "%-s\n" ---------------------------------------------------------
	printf "%-30s\t\t\t %-10s\n" TestCase  Result
	printf "%-30s\t\t\t %-10s\n" --------  ------
}


RetBrkParse(){
	let retTotal=retTPASSNum+retTFAILNum+retTCONFNum
	cat >&1 <<-EOF


--------------------
Total Tests: ${retTotal}
Total TPASS: ${retTPASSNum}
Total TFAIL: ${retTFAILNum}
Total TCONF: ${retTCONFNum}
Total ERROR: ${retERRORNum}
--------------------

Detailed: ${logPath}


	EOF
}

## TODO : 写入开始时间和Item name
## In   : $1=>Item name 
##      : $2=>logFile：日志文件路径
RetBrkStart(){
	#打印脚本名称
	printf "%-30s" "$1"
	
	local logFile=$2
	echo "##  Run $1 : $(date)" >> ${logFile}
}


## TODO : 写入结束时间和Item name
## In   : $1=>Item name 
##      : $2=>logFile：日志文件路径
RetBrkEnd(){
	local logFile=$2
	echo "## Finish $1 : $(date)" >> ${logFile}
}

## TODO : 写(TFAIL/TPASS/TCONF/ERROR)日志信息，统计测试项执行结果
## In   : $1=>TFAIL or TPASS or TCONF or ERROR
##        $2=>Item name 
##        $3=>Write to log file info
##        $4=>logFile：日志文件路径
RetBrk (){
	case $1 in
	TPASS|TFAIL|TCONF)
		RetBrkFailPassConf "$1" "$2"
		;;
	ERROR)
		if [ "$#" -eq "4" ];then
			RetBrkErr "$1" "$2" "$3" "$4"
		else
			RetBrkErr "$1" "$2"
		fi
		;;
	*)
		echo "Invalid parameter"
		;;
	esac
}

#------------- 内部静态函数 --------------#


## TODO : 写TFAIL和TPASS日志信息，工具测试结果统计
## In   : $1=>TFAIL or TPASS or TCONF
##        $2=>Item name 
RetBrkFailPassConf(){

	#统计TPASS TFAIL TCONF数据
	case $1 in
	TPASS)
		#打印脚本执行结果
                printf "\033[1m\033[;32m\t\t\t %-10s\033[0m\n" "$1"
		let retTPASSNum=retTPASSNum+1
		;;
	TFAIL)
		#打印脚本执行结果
                printf "\033[1m\033[;31m\t\t\t %-10s\033[0m\n" "$1"
		let retTFAILNum=retTFAILNum+1
		;;
	TCONF)
		#打印脚本执行结果
                printf "\033[1m\033[;33m\t\t\t %-10s\033[0m\n" "$1"
		let retTCONFNum=retTCONFNum+1
		;;
	esac

}

## TODO : 写ERROR日志，程序相关错误统计
## In   : $1=>ERROR
##        $2=>Item name 
##        $3=>Write to log file info
##        $4=>logFile：日志文件路径
RetBrkErr(){
	local logFile="$4"

	#打印脚本执行结果
        printf "%-30s\t\t\t %-10s\n" "$2" "$1"

	#统计ERROR数据
	let retERRORNum=retERRORNum+1

	if [ "$#" -eq "4" ];then
		echo "$(date)" >> $logFile
		echo "$1 : $3" >> $logFile
	fi
}

