
#!/bin/bash

PASSWORD_FILE="./password_manager.csv"

function validate_no_blank() {
	local input=$1

	if [[ "$input" =~ [[:space:]] ]]; then
		return 1
	fi

	return 0
}

function validate_input() {
	local service_name=$1
	local user_name=$2
	local password=$3
	local error_flg=0

	if [ -z "$service_name" ]; then
		echo "エラー：サービス名は必須です"
		error_flg=1
	elif grep -q "^$service_name," "$PASSWORD_FILE" 2>/dev/null; then
		echo "エラー：サービス名が重複しています"
		error_flg=1
	elif ! validate_no_blank "$service_name"; then
		echo "エラー：サービス名に空白が含まれています。"
		error_flg=1
	fi
	
	if [ -z "$user_name" ]; then
		echo "エラー：ユーザー名は必須です"
		error_flg=1
	elif ! validate_no_blank "$user_name"; then
                echo "エラー：ユーザー名に空白が含まれています。"
                error_flg=1
	fi

	if [ -z "$password" ]; then
		echo "エラー：パスワードは必須です"
		error_flg=1
	elif ! validate_no_blank "$password"; then
                echo "エラー：パスワードに空白が含まれています。"
                error_flg=1
	fi

	return $error_flg
}

function add_password() {
	local service_name=$1
        local user_name=$2
        local password=$3

	validate_input "$service_name" "$user_name" "$password"

        if [ $? -eq 1 ]; then
        	return
        fi

        echo "$service_name,$user_name,$password" >> "$PASSWORD_FILE"
        echo 'パスワードの追加は成功しました。'
}

function get_password() {
	local service_name=$1

	local search_rs=$(grep "^$service_name," "$PASSWORD_FILE" 2>/dev/null)

        if [ -n "$search_rs" ]; then
        	local service_name=$(echo "$search_rs" | cut -d , -f 1)
        	local user_name=$(echo "$search_rs" | cut -d , -f 2)
        	local password=$(echo "$search_rs" | cut -d , -f 3)

        	echo "サービス名：$service_name"
        	echo "ユーザー名：$user_name"
        	echo "パスワード：$password"
        else
        	echo 'そのサービスは登録されていません。'
        fi
}

function main() {
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

			add_password "$service_name" "$user_name" "$password"
        	elif [ "$option" = 'Get Password' ]; then
                	read -p 'サービス名を入力してください：' service_name
			get_password "$service_name"
        	else
                	echo '入力が間違えています。Add Password/Get Password/Exit から入力してください。'
        	fi
	done

	echo 'Thank you!'
}

# 処理実行
main

