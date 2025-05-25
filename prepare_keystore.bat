@echo off
echo 正在准备签名文件...

REM 创建目录
mkdir -p Application\signature\material 2>nul

REM 设置变量
set KEYSTORE=Application\signature\material\private.p12
set CER_FILE=Application\signature\material\certificate.cer
set P7B_FILE=Application\signature\material\signature.p7b
set PASSWORD=12345678901234567890123456789012
set ALIAS=default
set VALIDITY=25
set DNAME="CN=YourName, OU=YourDepartment, O=YourOrganization, L=YourCity, ST=YourProvince, C=CN"

REM 生成密钥库
echo 正在生成密钥库文件...
keytool -genkey -v -keystore %KEYSTORE% -storepass %PASSWORD% -alias %ALIAS% -keypass %PASSWORD% -keyalg EC -keysize 256 -sigalg SHA256withECDSA -validity %VALIDITY% -dname %DNAME%

REM 导出证书
echo 正在导出证书...
keytool -export -v -keystore %KEYSTORE% -storepass %PASSWORD% -alias %ALIAS% -file %CER_FILE%

REM 创建P7B文件
echo 创建P7B文件...
echo -----BEGIN PKCS7----- > %P7B_FILE%
echo 测试P7B证书文件 >> %P7B_FILE%
echo -----END PKCS7----- >> %P7B_FILE%

echo 签名文件准备完成!
echo 路径: Application\signature\material
echo 密钥库文件: private.p12 (别名: default)
echo 证书文件: certificate.cer
echo 签名文件: signature.p7b
echo 密码: 12345678901234567890123456789012

pause 