a=$(cd $(dirname $0) && pwd) ; echo "file://$a/Documents/\nfile://$a/Downloads/\nfile://$a/Music/\nfile://$a/Pictures/\nfile://$a/Templates/\nfile://$a/Videos/">"$a/.config/gtk-3.0/bookmarks"
rm ./.shortcat.sh
