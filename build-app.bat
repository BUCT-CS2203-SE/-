@echo off
echo 正在准备构建掌上博物馆应用...

REM 设置DevEco Studio路径
set DEVECO_PATH=E:\DevEco Studio
set PROJECT_PATH=D:\VSCODE\HandHeld_Museum\Application
set NODE_EXE=%DEVECO_PATH%\tools\node\node.exe
set HVIGOR_JS=%DEVECO_PATH%\tools\hvigor\bin\hvigorw.js

echo 您可以在DevEco Studio的终端中执行以下命令构建应用:
echo cd %PROJECT_PATH%
echo %NODE_EXE% %HVIGOR_JS% --mode release -p product=default assembleHap

echo 您也可以尝试:
echo 1. 打开DevEco Studio
echo 2. 打开终端窗口(底部的"Terminal"选项卡)
echo 3. 粘贴并执行以下命令:
echo    cd %PROJECT_PATH% ^&^& %NODE_EXE% %HVIGOR_JS% --mode release -p product=default assembleHap

echo 或者，您可以在DevEco Studio中使用菜单:
echo 1. 在DevEco Studio中选择 Build ^> Build Hap(s)/APP(s) ^> Build APP
echo 2. 选择 release 构建模式

echo 构建完成后的HAP包位置应为:
echo %PROJECT_PATH%\entry\build\outputs\hap\release\

echo.
echo 上传应用:
echo 构建成功后，请在DevEco Studio中选择 Tools ^> AppGallery Connect ^> Upload Product 上传应用

pause 