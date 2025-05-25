@echo off
echo 正在为掌上博物馆应用生成签名文件...

REM 设置变量
set KEYSTORE=Application\signature\palmmuseum.p12
set PASSWORD=12345678901234567890123456789012
set ALIAS=palmmuseum
set VALIDITY=25
set DNAME="CN=YourName, OU=YourDepartment, O=YourOrganization, L=YourCity, ST=YourProvince, C=CN"

REM 检查Java安装
where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 错误: 未找到Java，请安装Java JDK并确保java在PATH环境变量中
    exit /b 1
)

REM 检查keytool
where keytool >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 错误: 未找到keytool，请确保Java JDK bin目录在PATH环境变量中
    exit /b 1
)

REM 创建签名目录
if not exist Application\signature mkdir Application\signature

REM 生成密钥库和证书
echo 正在生成密钥库文件...
keytool -genkey -v -keystore %KEYSTORE% -storepass %PASSWORD% -alias %ALIAS% -keypass %PASSWORD% -keyalg EC -keysize 256 -sigalg SHA256withECDSA -validity %VALIDITY% -dname %DNAME%

if %ERRORLEVEL% NEQ 0 (
    echo 错误: 生成密钥库失败!
    exit /b 1
)

echo 正在导出证书...
keytool -export -v -keystore %KEYSTORE% -storepass %PASSWORD% -alias %ALIAS% -file Application\signature\palmmuseum.cer

REM 创建一个空的P7B文件（在正式环境中，这应由华为签发，这里仅用于测试）
echo 创建P7B文件...
echo -----BEGIN PKCS7----- > Application\signature\palmmuseum.p7b
echo 测试P7B证书文件 >> Application\signature\palmmuseum.p7b
echo -----END PKCS7----- >> Application\signature\palmmuseum.p7b

echo 密钥库和证书已生成完成!

REM 更新build-profile.json5确保签名配置正确
echo 请确认Application/build-profile.json5中的签名配置已正确设置

REM 使用hvigor构建应用
echo 正在构建应用...

REM 检查hvigor是否安装
where hvigor >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 注意: 未找到hvigor命令行工具
    echo 以下是在DevEco Studio终端中构建应用的命令:
    echo   cd Application
    echo   ..\node_modules\.bin\hvigor --mode release
    
    REM 尝试使用node_modules中的hvigor
    if exist node_modules\.bin\hvigor.cmd (
        echo 找到node_modules中的hvigor，尝试使用...
        cd Application
        ..\node_modules\.bin\hvigor.cmd --mode release
        cd ..
    ) else (
        echo 未找到hvigor工具，请在DevEco Studio中构建应用
    )
) else (
    hvigor --mode release
    if %ERRORLEVEL% NEQ 0 (
        echo 构建失败，请查看错误信息
    ) else (
        echo 应用构建成功!
        echo HAP包位置: Application\entry\build\outputs\hap\release\
    )
)

echo 脚本执行完成!
echo 如果生成的签名文件无法使用，或者构建失败，请尝试在DevEco Studio中操作:
echo 1. 打开DevEco Studio
echo 2. 使用Tools菜单生成签名
echo 3. 使用Build菜单构建应用

pause 