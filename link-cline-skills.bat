@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

echo ========================================================
echo   Access Lib — Agentic AI Skills Linker (Office/Home)
echo ========================================================
echo.

:: 1. ดึงตำแหน่งโฟลเดอร์ปัจจุบันของคลังนี้แบบอัตโนมัติ (รองรับทุกเครื่อง/ทุกตำแหน่ง OneDrive)
set "REPO_ROOT=%~dp0"
:: ลบเครื่องหมาย backslash ตัวสุดท้ายออกเพื่อความสะอาดของ Path
if "%REPO_ROOT:~-1%"=="\" set "REPO_ROOT=%REPO_ROOT:~0,-1%"
set "SKILLS_SRC=%REPO_ROOT%\skills"

:: 2. ตรวจสอบว่ามีโฟลเดอร์ skills ต้นทางอยู่จริงหรือไม่
if not exist "%SKILLS_SRC%" (
    echo [ERROR] ไม่พบโฟลเดอร์ต้นทาง: "%SKILLS_SRC%"
    echo กรุณาตรวจสอบว่าไฟล์ .bat นี้อยู่ในโฟลเดอร์หลักของ .cline-skills
    pause
    exit /b 1
)

echo [INFO] โฟลเดอร์ต้นทาง (OneDrive/Repo): "%SKILLS_SRC%"
echo [INFO] โปรไฟล์ผู้ใช้ของเครื่องนี้: "%USERPROFILE%"
echo.

:: 3. เตรียมโฟลเดอร์ปลายทางในเครื่องปัจจุบัน (~/.cline/skills และ ~/.agents/skills)
set "TARGETS="%USERPROFILE%\.cline\skills" "%USERPROFILE%\.agents\skills""

for %%T in (%TARGETS%) do (
    set "TARGET_DIR=%%~T"
    echo --------------------------------------------------------
    echo กำลังตั้งค่าปลายทาง: "!TARGET_DIR!"
    
    if not exist "!TARGET_DIR!" (
        mkdir "!TARGET_DIR!" >nul 2>&1
    )

    :: วนลูปสร้าง Directory Junction สำหรับแต่ละ Skill
    for /D %%S in ("%SKILLS_SRC%\*") do (
        set "SKILL_NAME=%%~nxS"
        set "LINK_PATH=!TARGET_DIR!\!SKILL_NAME!"

        :: หากมีลิงก์หรือโฟลเดอร์เดิมอยู่ ให้ลบตัว Junction เดิมออกก่อน (ไม่ลบไฟล์จริงในต้นทาง)
        if exist "!LINK_PATH!" (
            rmdir "!LINK_PATH!" >nul 2>&1
        )

        :: สร้าง Directory Junction ใหม่
        mklink /J "!LINK_PATH!" "%%~fS" >nul 2>&1
        if !errorlevel! equ 0 (
            echo   [OK] เชื่อมโยงทักษะ: !SKILL_NAME!
        ) else (
            echo   [FAIL] ไม่สามารถเชื่อมโยง: !SKILL_NAME!
        )
    )
)

echo.
echo --------------------------------------------------------
:: 4. ตั้งค่า Git Hooks ของคลังกลาง (ถ้ามีโฟลเดอร์ .githooks)
if exist "%REPO_ROOT%\.githooks" (
    echo [INFO] กำลังตั้งค่า Git hooks path...
    git -C "%REPO_ROOT%" config core.hooksPath .githooks >nul 2>&1
    echo   [OK] ตั้งค่า Git hooks เรียบร้อยแล้ว
)

echo.
echo ========================================================
echo   [SUCCESS] ติดตั้งและเชื่อมโยง Skills สำหรับเครื่องนี้สำเร็จ!
echo ========================================================
echo.
pause
