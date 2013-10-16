@ECHO OFF
FOR %%I IN (*.apk) DO (
	ECHO signing %%I
	IF NOT EXIST OUT MD OUT
	java -Xmx1024m -jar signapk.jar -w platform.x509.pem platform.pk8 %%I OUT\signed_%%I
	ECHO %%I was signed and rename to signed_%%I
	ECHO All APK files were Signed Complete!
)
PAUSE
@ECHO ON