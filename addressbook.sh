#! /bin/bash
#
# Jeonggyuny <Jeonggyuny@protonmail.com>

ADDRESS_BOOK=./addressbook.txt

DELIMITER=:
NAME_FIELD=1
PHONE_FIELD=2
EMAIL_FIELD=3

Confirm() {
	echo "Are you sure? [Yes/No]"
	read ANSWER

	case $ANSWER in
		Yes)
			;;

		No)
			break ;;

		*)
			echo "Invalid answer" ;;
	esac
}

Search() {
	echo -n "Search address book: "
	read PATTERN
	COUNT=`grep -c $PATTERN $ADDRESS_BOOK`
	if [ $COUNT -eq 0 ]; then
		echo "Failed to search"

		return
	fi

	grep $PATTERN $ADDRESS_BOOK \
		| cut -d $DELIMITER -f $NAME_FIELD,$PHONE_FIELD,$EMAIL_FIELD \
		| awk -F $DELIMITER '{print "Name: " $1 "\tPhone number: " $2 "\tEmail address: " $3}'
	echo "$COUNT Found"
}

Add() {
	echo -n "What is your name: "
	read NAME

	echo -n "What is your phone number: "
	read PHONE
	
	echo -n "What is your email address: "
	read EMAIL

	echo "Name: $NAME"
	echo "Phone number: $PHONE"
	echo "Email address: $EMAIL"
	Confirm
	
	echo "$NAME:$PHONE:$EMAIL" >> $ADDRESS_BOOK
	echo "Done"
}

Remove() {
	echo -n "I want to remove record that contain [Name|Phone|Email]: "
	read CRITERIA
	if [ $CRITERIA != "Name" -a $CRITERIA != "Phone" -a $CRITERIA != "Email" ]; then
		echo "Failed to edit"

		return
	fi

	if [ $CRITERIA = "Name" ]; then
		echo -n "What is your name: "
		read PATTERN
		COUNT=`cut -d $DELIMITER -f $NAME_FIELD $ADDRESS_BOOK | grep -c $PATTERN`
		if [ $COUNT -eq 0 ]; then
			echo "Failed to remove"

			return
		fi
		
		I=1
		while [ $I -le $COUNT ]; do
			RET=`cut -d $DELIMITER -f $NAME_FIELD $ADDRESS_BOOK \
				| grep -n $PATTERN | awk -F $DELIMITER 'NR == 1 {print $1}'`

			sed -i "$RET"d $ADDRESS_BOOK

			I=`expr $I + 1`
		done

	elif [ $CRITERIA = "Phone" ]; then
		echo -n "What is your phone number: "
		read PATTERN
		COUNT=`cut -d $DELIMITER -f $PHONE_FIELD $ADDRESS_BOOK | grep -c $PATTERN`
		if [ $COUNT -eq 0 ]; then
			echo "Failed to remove"

			continue
		fi

		I=1
		while [ $I -le $COUNT ]; do
			RET=`cut -d $DELIMITER -f $PHONE_FIELD $ADDRESS_BOOK \
				| grep -n $PATTERN | awk -F $DELIMITER 'NR == 1 {print $1}'`

			sed -i "$RET"d $ADDRESS_BOOK

			I=`expr $I + 1`
		done

	elif [ $CRITERIA = "Email" ]; then
		echo -n "What is your email address: "
		read PATTERN
		COUNT=`cut -d $DELIMITER -f $EMAIL_FIELD $ADDRESS_BOOK | grep -c $PATTERN`
		if [ $COUNT -eq 0 ]; then
			echo "Failed to remove"

			continue
		fi

		I=1
		while [ $I -le $COUNT ]; do
			RET=`cut -d $DELIMITER -f $EMAIL_FIELD $ADDRESS_BOOK \
				| grep -n $PATTERN | awk -F $DELIMITER 'NR == 1 {print $1}'`

			sed -i "$RET"d $ADDRESS_BOOK

			I=`expr $I + 1`
		done

	fi
}

Edit() {
	echo -n "What would you like to edit [Name|Phone|Email]: "
	read CRITERIA
	if [ $CRITERIA != "Name" -a $CRITERIA != "Phone" -a $CRITERIA != "Email" ]; then
		echo "Failed to edit"

		return
	fi

	# Assuming that only phone number is unique
	echo -n "What is your phone number: "
	read PATTERN
	COUNT=`grep -c $PATTERN $ADDRESS_BOOK`
	if [ $COUNT -ne 1 ]; then
		echo "Please enter in detail"

		return
	fi

	RET=`grep $PATTERN $ADDRESS_BOOK`
	RET_NAME=${RET%%:*}
	echo "Hello $RET_NAME!"

	if [ $CRITERIA = "Name" ]; then
		echo -n "What is name you want to edit: "
		read NEW_NAME
		RET=`cut -d $DELIMITER -f $PHONE_FIELD $ADDRESS_BOOK \
			| grep -n $PATTERN | awk -F $DELIMITER 'NR == 1 {print $1}'`

		OLD_NAME=`awk -v i=$RET 'NR == i {print $1}' $ADDRESS_BOOK \
			| cut -d $DELIMITER -f $NAME_FIELD`

		sed -i "$RET"s/$OLD_NAME/$NEW_NAME/ $ADDRESS_BOOK

		echo "Done"

	elif [ $CRITERIA = "Phone" ]; then
		echo -n "What is phone number you want to edit: "
		read NEW_PHONE

		RET=`cut -d $DELIMITER -f $PHONE_FIELD $ADDRESS_BOOK \
			| grep -n $PATTERN | awk -F $DELIMITER 'NR == 1 {print $1}'`

		OLD_PHONE=`awk -v i=$RET 'NR == i {print $1}' $ADDRESS_BOOK \
			| cut -d $DELIMITER -f $PHONE_FIELD`

		sed -i "$RET"s/$OLD_PHONE/$NEW_PHONE/ $ADDRESS_BOOK

		echo "Done"

	elif [ $CRITERIA = "Email" ]; then
		echo -n "What is email address you want to edit: "
		read NEW_EMAIL

		RET=`cut -d $DELIMITER -f $PHONE_FIELD $ADDRESS_BOOK \
			| grep -n $PATTERN | awk -F $DELIMITER 'NR == 1 {print $1}'`

		OLD_EMAIL=`awk -v i=$RET 'NR == i {print $1}' $ADDRESS_BOOK \
			| cut -d $DELIMITER -f $EMAIL_FIELD`

		sed -i "$RET"s/$OLD_EMAIL/$NEW_EMAIL/ $ADDRESS_BOOK

		echo "Done"
	fi
}

select FUNC in Search Add Remove Edit Quit
do
	case $FUNC in
		Search)
			Search ;;

		Add)
			Add ;;

		Remove)
			Remove ;;

		Edit)
			Edit ;;

		Quit)
			break ;;

		*)
			echo "Invalid argument" ;;
	esac
done
