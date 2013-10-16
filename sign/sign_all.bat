@ECHO OFF
FOR %%I IN (*.zip) DO (
	ECHO signing %%I
	IF NOT EXIST OUT MD OUT
	java -Xmx1024m -jar signapk.jar -w testkey.x509.pem testkey.pk8 %%I OUT\signed_%%I
	ECHO %%I was signed and rename to signed_%%I
	ECHO All files were Signed Complete!
)
PAUSE
@ECHO ON