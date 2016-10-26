#!/bin/bash
blocks=`qubitcoin-cli getinfo | grep blocks | cut -d " " -f 7 | cut -d "," -f 1`
date=`date -u`
date_fmt=`date -u +%Y%m%d`
file="bootstrap.dat"
file_xz="$file.$date_fmt.tar.xz"
file_zip="$file.$date_fmt.zip"
file_sha256="sha256.txt"
header=`cat header.md`
prevLinks=`head links.md`
footer=`cat footer.md`
#mainnet
./linearize-hashes.py linearize.cfg > hashlist.txt
./linearize-data.py linearize.cfg 
touch $file_sha256
tar cJf $file_xz $file
zip $file_zip $file
sha256sum $file $file_xz $file_zip > $file_sha256
size_xz=`ls -lh $file_xz | awk -F" " '{ print $5 }'`
size_zip=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
url_xz=`curl --upload-file $file_xz https://transfer.sh/$file_xz`
url_zip=`curl --upload-file $file_zip https://transfer.sh/$file_zip`
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
newLinks="Block $blocks: $date [xz]($url_xz) ($size_xz) [zip]($url_zip) ($size_zip) [SHA256]($url_sha256)\n\n$prevLinks"
echo -e "$newLinks" > links.md
rm $file $file_xz $file_zip $file_sha256 hashlist.txt
echo -e "$header\n\n####For mainnet:\n\n$newLinks\n\n$footer" > README.md
#push
git add *.md
git commit -m "$date - autoupdate"
git push
