@echo off
echo 正在准备导入签名配置...

REM 设置DevEco Studio路径
set DEVECO_PATH=E:\DevEco Studio
set PROJECT_PATH=D:\VSCODE\HandHeld_Museum\Application
set NODE_EXE=%DEVECO_PATH%\tools\node\node.exe
set HVIGOR_JS=%DEVECO_PATH%\tools\hvigor\bin\hvigorw.js

echo 在DevEco Studio终端中，执行以下命令:

echo 方法1: 使用命令行工具
echo cd %PROJECT_PATH%
echo %NODE_EXE% %HVIGOR_JS% --mode release -p product=default assembleHap

echo 方法2: 在DevEco Studio图形界面中:
echo 1. 打开DevEco Studio
echo 2. 选择 File ^> Project Structure
echo 3. 选择 Modules ^> entry ^> Signing Configs
echo 4. 点击 + 添加新配置
echo 5. 输入以下信息:
echo    - Name: default
echo    - Key store password: 12345678901234567890123456789012 (32个字符)
echo    - Key alias: default
echo    - Key password: 12345678901234567890123456789012 (32个字符)
echo    - 密钥库文件路径: %PROJECT_PATH%\signature\material\private.p12
echo    - 签名文件路径: %PROJECT_PATH%\signature\material\signature.p7b
echo    - 证书文件路径: %PROJECT_PATH%\signature\material\certificate.cer
echo 6. 点击应用并确定
echo 7. 在顶部菜单选择 Build ^> Build Hap(s)/APP(s) ^> Build APP

echo.
echo 提示: 如果还是遇到问题，尝试在DevEco Studio中创建一个全新的项目并创建新的签名配置

pause 