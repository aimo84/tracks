wget --save-cookies cookies.txt \
--keep-session-cookies  \
--post-data 'user_login=admin&user_password=password'  \
--delete-after http://tracksnew-jwyoung.c9users.io:8080/login

wget -r -l 3 --load-cookies cookies.txt -e robots=off \
http://tracksnew-jwyoung.c9users.io:8080 --delete-after --no-cache
