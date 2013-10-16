#!/bin/bash
#设定要签名的apk文件后缀
filetype=apk
#找出当前目录下（不包含子文件夹）未签名过的并且以filetype为后缀的文件
find . -maxdepth 1 -name "*.$filetype" -and -not -name "*_signed.$filetype"| while read fname
do
  echo "signing $fname";
  #签名
  java -Xmx256m -jar signapk.jar -w platform.x509.pem platform.pk8 $fname ${fname%.$filetype}_signed.$filetype
  #java -Xmx2048m -jar signapk.jar -w testkey.x509.pem testkey.pk8 $fname ${fname%.$filetype}_signed.$filetype
  echo "$fname was signed and rename to ${fname%.$filetype}_signed.$filetype"
  #判断签名后的文件是否存在，若存在说明签名成功删除源文件，如内存不够等原因有可能存在签名不成功则不删除源文件。
  if   [ -e ${fname%.$filetype}_signed.$filetype ] 
  then 
    rm $fname
  fi
done
echo "All $filetype files were Signed Complete!"
