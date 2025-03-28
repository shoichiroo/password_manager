
#!/bin/bash

function validate_input() {
	local service_name=$1
	local user_name=$2
	local password=$3
	local error_flg=0

	if [ -z "$service_name" ]; then
		echo "エラー：サービス名は必須です"
		error_flg=1
	elif grep "^$service_name," ./password_manager.csv > /dev/null 2>&1; then
		echo "エラー：サービス名が重複しています"
		error_flg=1
	fi
	
	if [ -z "$user_name" ]; then
		echo "エラー：ユーザー名は必須です"
		error_flg=1
	fi

	if [ -z "$password" ]; then
		echo "エラー：パスワードは必須です"
		error_flg=1
	fi

	return $error_flg
}

function main() {
	local service_name=""
	local user_name=""
	local password=""

	echo 'パスワードマネージャーへようこそ！'

	# 'Exit'が入力されるまで、無限ループする。
	while true
	do
        	read -p '次の選択肢から入力してください(Add Password/Get Password/Exit)：' option

        	if [ "$option" = 'Exit' ]; then
                	break
        	elif [ "$option" = 'Add Password' ]; then
                	read -p 'サービス名を入力してください：' service_name
                	read -p 'ユーザー名を入力してください：' user_name
                	read -p 'パスワードを入力してください：' password

                	validate_input "$service_name" "$user_name" "$password"
                	validate_rs=$?

                	if [ $validate_rs -eq 1 ]; then
                        	continue
                	fi

                	echo "$service_name,$user_name,$password" >> password_manager.csv
                	echo 'パスワードの追加は成功しました。'
        	elif [ "$option" = 'Get Password' ]; then
                	read -p 'サービス名を入力してください：' service_name

                	search_rs=$(grep "^$service_name," ./password_manager.csv)

                	if [ -n "$search_rs" ]; then
                        	service_name=$(echo $search_rs | cut -d , -f 1)
                        	user_name=$(echo $search_rs | cut -d , -f 2)
                        	password=$(echo $search_rs | cut -d , -f 3)

                        	echo "サービス名：$service_name"
                        	echo "ユーザー名：$user_name"
                        	echo "パスワード：$password"
                	else
                        	echo 'そのサービスは登録されていません。'
                	fi
        	else
                	echo '入力が間違えています。Add Password/Get Password/Exit から入力してください。'
        	fi
	done

	echo 'Thank you!'
}

main

