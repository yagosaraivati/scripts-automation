@echo off
chcp 850 >nul
setlocal EnableExtensions DisableDelayedExpansion
title Ferramentas para o Suporte Tecnico
mode con: cols=80 lines=62

:: ================= CONFIGURACOES =================
set "VERSAO=2.0.0"
set "LOG_FILE=%~dp0painel_log.txt"

:: ================= ADMIN =================
net session >nul 2>&1
if errorlevel 1 (
    echo Execute este script como ADMINISTRADOR.
    pause
    exit /b
)

:: =====================================
:: MAPA: numero do menu -> rotina EXP_x
:: =====================================
:: LIMPEZA
set "MAP_1=1"  & set "MAP_2=2"  & set "MAP_3=8"  & set "MAP_4=31" & set "MAP_5=36" & set "MAP_6=37"
:: REPARO
set "MAP_7=3"  & set "MAP_8=4"  & set "MAP_9=38" & set "MAP_10=5" & set "MAP_11=6" & set "MAP_12=15"
:: DESEMPENHO
set "MAP_13=27" & set "MAP_14=28" & set "MAP_15=29" & set "MAP_16=30"
set "MAP_17=32" & set "MAP_18=34" & set "MAP_19=35" & set "MAP_20=12"
:: DIAGNOSTICO
set "MAP_21=9"  & set "MAP_22=10" & set "MAP_23=11" & set "MAP_24=13" & set "MAP_25=14" & set "MAP_26=19"
set "MAP_27=23" & set "MAP_28=24" & set "MAP_29=33" & set "MAP_30=39" & set "MAP_31=40" & set "MAP_32=26"
:: SEGURANCA / REDE
set "MAP_33=20" & set "MAP_34=41" & set "MAP_35=17" & set "MAP_36=21" & set "MAP_37=18"
set "MAP_38=7"  & set "MAP_39=22" & set "MAP_40=25" & set "MAP_41=16"
set "MAX_OPCAO=41"

:: ================= CORES =================
:COR
cls
echo ================================================
echo            SELECIONE A COR DO PAINEL
echo                0 a 7 Cor do Fundo
echo                8 a F Cor do Texto
echo ------------------------------------------------
echo 0 = Preto       8 = Cinza
echo 1 = Azul        9 = Azul claro
echo 2 = Verde       A = Verde claro
echo 3 = Aqua        B = Aqua claro
echo 4 = Vermelho    C = Vermelho claro
echo 5 = Roxo        D = Roxo claro
echo 6 = Amarelo     E = Amarelo claro
echo 7 = Branco      F = Branco brilhante
echo ------------------------------------------------
echo.
set "cor="
set /p "cor=Codigo da cor (ENTER = padrao): "
if not defined cor ( color 07 & goto MENU )
echo %cor%| findstr /R /I "^[0-9A-F][0-9A-F]$" >nul || (
    echo Codigo invalido.
    pause
    goto COR
)
color %cor% || color 07
goto MENU

:MENU
cls
echo ===============================================================
echo                 PAINEL DE SUPORTE TECNICO  v%VERSAO%
echo ===============================================================
echo.
echo  -- LIMPEZA --
echo  [1]  Temporarios do usuario
echo  [2]  Limpeza de disco (cleanmgr)
echo  [3]  Limpeza seletiva de logs
echo  [4]  Limpeza de componentes WinSxS
echo  [5]  Cache do Delivery Optimization
echo  [6]  Cache de miniaturas
echo.
echo  -- REPARO --
echo  [7]  Verificacao de arquivos (SFC)
echo  [8]  Reparo da imagem (DISM)
echo  [9]  Reparo completo (DISM + SFC)
echo  [10] Reset do Windows Update
echo  [11] Reset de configuracoes de rede
echo  [12] CHKDSK no disco C:
echo.
echo  -- DESEMPENHO --
echo  [13] Liberar recursos (submenu)
echo  [14] Criar ponto de restauracao
echo  [15] Plano de energia
echo  [16] Otimizar unidades (TRIM/Defrag)
echo  [17] Programas na inicializacao
echo  [18] Efeitos visuais
echo  [19] Desativar hibernacao
echo  [20] Atualizar programas (winget)
echo.
echo  -- DIAGNOSTICO --
echo  [21] Informacoes do sistema (msinfo32)
echo  [22] Gerenciador de dispositivos
echo  [23] Adaptadores de rede
echo  [24] Processos em execucao
echo  [25] Servicos ativos
echo  [26] Espaco em disco
echo  [27] Dispositivos USB
echo  [28] Uso de memoria e CPU
echo  [29] Saude dos discos
echo  [30] Diagnostico de memoria
echo  [31] Relatorio de bateria
echo  [32] Relatorio de politicas (gpresult)
echo.
echo  -- SEGURANCA / REDE --
echo  [33] Status do antivirus
echo  [34] Verificacao rapida do Defender
echo  [35] Verificar ipconfig
echo  [36] Ping continuo (Google)
echo  [37] Teste de velocidade
echo  [38] Atualizar politicas (gpupdate)
echo  [39] Backup dos logs de eventos
echo  [40] Baixar arquivo via HTTPS
echo  [41] Abrir PowerShell
echo.
echo  [99] Mudar cor
echo  [0]  Sair
echo.
set "opcao="
set /p "opcao=Escolha uma opcao: "

:: =====================================
:: VALIDACAO DE ENTRADA
:: =====================================
if not defined opcao goto INVALIDA
if "%opcao%"=="0"  exit
if "%opcao%"=="99" goto COR

:: Aceita somente digitos
for /f "delims=0123456789" %%a in ("%opcao%") do goto INVALIDA

:: Remove zeros a esquerda (ex.: 07 -> 7)
for /f "tokens=* delims=0" %%z in ("%opcao%") do set "opcao=%%z"
if not defined opcao goto INVALIDA

:: Limita a 3 digitos (evita estouro numerico)
if not "%opcao:~3%"=="" goto INVALIDA

if %opcao% lss 1 goto INVALIDA
if %opcao% gtr %MAX_OPCAO% goto INVALIDA

:: Busca a rotina no mapa (sem precisar de delayed expansion)
set "DEST="
call set "DEST=%%MAP_%opcao%%%"
if not defined DEST goto INVALIDA
goto EXP_%DEST%

:INVALIDA
echo Opcao invalida.
pause
goto MENU

:: ================= AUXILIARES =================
:INFO
cls
echo %~1
echo ------------------------------------------------
echo O que faz: %~2
echo Tempo estimado: %~3
echo Afeta arquivos pessoais? %~4
echo.
set "escolha="
set /p "escolha=Deseja executar? (1=Sim / 0=Voltar): "
goto :eof

:LOG
>>"%LOG_FILE%" echo [%date% %time%] %~1
goto :eof

:CONFIRMAR
set "CONF="
set /p "CONF=Tem certeza? (S/N): "
if /I "%CONF%"=="S" exit /b 0
echo Operacao cancelada.
pause
exit /b 1

:: ================= ROTINAS =================
:EXP_1
call :INFO "[1] Temporarios do usuario" "Apaga arquivos em %%TEMP%%. Arquivos em uso sao ignorados." "1 a 2 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :LOG "Limpeza temp usuario"
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1
echo Limpeza concluida.
pause
goto MENU

:EXP_2
call :INFO "[2] Limpeza de disco" "Abre o cleanmgr." "2 a 5 min" "Nao"
if "%escolha%"=="1" start "" cleanmgr
goto MENU

:EXP_3
call :INFO "[3] SFC" "Verifica e repara arquivos protegidos do Windows." "10 a 30 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :CONFIRMAR || goto MENU
call :LOG "sfc /scannow"
sfc /scannow
pause
goto MENU

:EXP_4
call :INFO "[4] DISM" "Repara a imagem do Windows (requer internet)." "10 a 20 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :LOG "DISM restorehealth"
dism /online /cleanup-image /restorehealth
pause
goto MENU

:EXP_5
call :INFO "[5] Reset do Windows Update" "Para servicos, recria SoftwareDistribution e catroot2." "5 a 10 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :CONFIRMAR || goto MENU
call :LOG "Reset Windows Update"
for %%s in (wuauserv bits cryptsvc msiserver) do net stop %%s >nul 2>&1
rd /s /q "%WINDIR%\SoftwareDistribution" >nul 2>&1
rd /s /q "%WINDIR%\System32\catroot2" >nul 2>&1
for %%s in (msiserver cryptsvc bits wuauserv) do net start %%s >nul 2>&1
echo Reset concluido.
pause
goto MENU

:EXP_6
call :INFO "[6] Reset de rede" "Reseta DNS, Winsock e TCP/IP. Exige reinicializacao." "1 a 3 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :CONFIRMAR || goto MENU
call :LOG "Reset de rede"
ipconfig /flushdns
netsh winsock reset
netsh int ip reset
echo Reinicie o computador.
pause
goto MENU

:EXP_7
call :INFO "[7] gpupdate" "Atualiza politicas de grupo." "1 a 2 min" "Nao"
if "%escolha%"=="1" ( gpupdate /force & pause )
goto MENU

:EXP_8
call :INFO "[8] Limpeza seletiva de logs" "Backup e limpeza de Application e Setup. Security preservado." "1 a 2 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :CONFIRMAR || goto MENU
set "EVENT_BACKUP=%USERPROFILE%\BackupEventos"
if not exist "%EVENT_BACKUP%" mkdir "%EVENT_BACKUP%"
call :LOG "Limpeza logs Application/Setup"
wevtutil epl Application "%EVENT_BACKUP%\Application_%RANDOM%.evtx" >nul 2>&1
wevtutil epl Setup "%EVENT_BACKUP%\Setup_%RANDOM%.evtx" >nul 2>&1
wevtutil cl Application
wevtutil cl Setup
echo Backup em "%EVENT_BACKUP%". Logs limpos.
pause
goto MENU

:EXP_9
call :INFO "[9] msinfo32" "Informacoes detalhadas do sistema." "Instantaneo" "Nao"
if "%escolha%"=="1" start "" msinfo32
goto MENU

:EXP_10
call :INFO "[10] Gerenciador de dispositivos" "Abre devmgmt.msc." "Instantaneo" "Nao"
if "%escolha%"=="1" start "" devmgmt.msc
goto MENU

:EXP_11
call :INFO "[11] Adaptadores de rede" "ipconfig /all." "Instantaneo" "Nao"
if "%escolha%"=="1" ( ipconfig /all & pause )
goto MENU

:EXP_12
call :INFO "[12] winget" "Lista atualizacoes e permite atualizar tudo." "Variavel" "Nao"
if not "%escolha%"=="1" goto MENU
where winget >nul 2>&1 || ( echo winget nao encontrado. & pause & goto MENU )
winget upgrade
set "UPALL="
set /p "UPALL=Atualizar todos agora? (S/N): "
if /I "%UPALL%"=="S" (
    call :LOG "winget upgrade --all"
    winget upgrade --all --accept-source-agreements --accept-package-agreements
)
pause
goto MENU

:EXP_13
call :INFO "[13] Processos" "Top 20 processos por uso de memoria." "Instantaneo" "Nao"
if "%escolha%"=="1" (
    powershell -NoProfile -Command "Get-Process | Sort-Object WS -Descending | Select-Object -First 20 Name,Id,@{N='RAM_MB';E={[math]::Round($_.WS/1MB)}},CPU | Format-Table -AutoSize"
    pause
)
goto MENU

:EXP_14
call :INFO "[14] Servicos ativos" "Lista servicos em execucao." "Instantaneo" "Nao"
if "%escolha%"=="1" ( net start & pause )
goto MENU

:EXP_15
call :INFO "[15] CHKDSK C:" "Agenda verificacao com reparo no proximo boot. Em HD pode levar horas." "Variavel" "Nao"
if not "%escolha%"=="1" goto MENU
call :CONFIRMAR || goto MENU
call :LOG "chkdsk C: /f /r"
echo S| chkdsk C: /f /r
echo Verificacao agendada para a proxima reinicializacao.
pause
goto MENU

:EXP_16
call :INFO "[16] PowerShell" "Abre o PowerShell." "Instantaneo" "Nao"
if "%escolha%"=="1" start "" powershell
goto MENU

:EXP_17
call :INFO "[17] ipconfig" "Informacoes de IP." "Instantaneo" "Nao"
if "%escolha%"=="1" ( ipconfig & pause )
goto MENU

:EXP_18
call :INFO "[18] Speedtest" "Abre speedtest.net." "Instantaneo" "Nao"
if "%escolha%"=="1" start "" "https://www.speedtest.net"
goto MENU

:EXP_19
call :INFO "[19] Espaco em disco" "Espaco livre por unidade." "Instantaneo" "Nao"
if "%escolha%"=="1" (
    powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID,@{N='TotalGB';E={[math]::Round($_.Size/1GB,1)}},@{N='LivreGB';E={[math]::Round($_.FreeSpace/1GB,1)}},@{N='Livre%%';E={[math]::Round($_.FreeSpace*100/$_.Size)}} | Format-Table -AutoSize"
    pause
)
goto MENU

:EXP_20
call :INFO "[20] Antivirus" "Lista antivirus registrados e estado." "Instantaneo" "Nao"
if "%escolha%"=="1" (
    powershell -NoProfile -Command "Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntivirusProduct | ForEach-Object { $h='{0:X6}' -f $_.productState; $_.displayName + ' | Ativo: ' + ($h.Substring(2,2) -in '10','11') + ' | Atualizado: ' + ($h.Substring(4,2) -eq '00') }"
    pause
)
goto MENU

:EXP_21
call :INFO "[21] Ping Google" "Ping continuo (Ctrl+C para parar)." "Continuo" "Nao"
if "%escolha%"=="1" ping www.google.com -t
goto MENU

:EXP_22
call :INFO "[22] Backup de logs" "Exporta Application, System, Setup e Security." "1 a 2 min" "Nao"
if not "%escolha%"=="1" goto MENU
set "EVENT_BACKUP=%USERPROFILE%\BackupEventos"
if not exist "%EVENT_BACKUP%" mkdir "%EVENT_BACKUP%"
call :LOG "Backup logs de eventos"
for %%L in (Application System Setup Security) do wevtutil epl %%L "%EVENT_BACKUP%\%%L_%RANDOM%.evtx" >nul 2>&1
echo Backup em "%EVENT_BACKUP%".
pause
goto MENU

:EXP_23
call :INFO "[23] Dispositivos USB" "Lista dispositivos USB conectados." "Instantaneo" "Nao"
if "%escolha%"=="1" (
    powershell -NoProfile -Command "Get-CimInstance Win32_PnPEntity | Where-Object { $_.DeviceID -like 'USB*' } | Select-Object Name,Status | Format-Table -AutoSize"
    pause
)
goto MENU

:EXP_24
cls
echo [24] Uso de memoria e CPU
echo ----------------------------------------
powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; $t=[math]::Round($o.TotalVisibleMemorySize/1KB); $l=[math]::Round($o.FreePhysicalMemory/1KB); $u=$t-$l; $c=(Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average; 'Memoria: {0} MB / {1} MB [{2}%%]' -f $u,$t,[math]::Round($u*100/$t); 'CPU: {0}%%' -f $c; 'Ligado ha: ' + ((Get-Date)-$o.LastBootUpTime).ToString('d\d\ hh\h\ mm\m')"
echo.
pause
goto MENU

:EXP_25
cls
echo [25] Baixar arquivo via HTTPS
echo ------------------------------------------------
set "url="
set /p "url=Cole o link HTTPS: "
if not defined url goto MENU
call :LOG "Download HTTPS solicitado"
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; try { $u=[Uri]$env:url; if($u.Scheme -ne 'https'){throw 'Somente HTTPS.'}; $n=[IO.Path]::GetFileName($u.AbsolutePath); if(-not $n){$n='downloaded_file'}; $n=$n -replace '[\\/:*?\"<>|]','_'; $d=Join-Path ([Environment]::GetFolderPath('UserProfile')) ('Downloads\'+$n); [Net.ServicePointManager]::SecurityProtocol='Tls12'; Invoke-WebRequest -Uri $u -OutFile $d -UseBasicParsing; $f=Get-Item -LiteralPath $d; if($f.Length -le 0){Remove-Item $d; throw 'Arquivo vazio.'}; 'Salvo: '+$f.FullName; 'Tamanho: '+$f.Length+' bytes'; 'SHA256: '+(Get-FileHash -LiteralPath $d).Hash } catch { 'ERRO: '+$_.Exception.Message; exit 1 }"
echo.
echo Confira a origem e o SHA256 antes de executar o arquivo.
pause
goto MENU

:EXP_26
call :INFO "[26] gpresult" "Politicas aplicadas e relatorio HTML na Area de Trabalho." "Imediato" "Nao"
if not "%escolha%"=="1" goto MENU
gpresult /R
gpresult /H "%USERPROFILE%\Desktop\gpresult.html" /F >nul 2>&1 && echo Relatorio salvo em Desktop\gpresult.html
pause
goto MENU

:: ================= NOVAS FUNCOES =================
:EXP_28
call :INFO "[28] Ponto de restauracao" "Cria um ponto de restauracao. Recomendado antes de qualquer reparo." "1 a 3 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :LOG "Ponto de restauracao"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v SystemRestorePointCreationFrequency /t REG_DWORD /d 0 /f >nul
powershell -NoProfile -Command "try { Enable-ComputerRestore -Drive \"$env:SystemDrive\\\" ; Checkpoint-Computer -Description 'Painel Suporte' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; 'Ponto criado.' } catch { 'ERRO: ' + $_.Exception.Message }"
pause
goto MENU

:EXP_29
cls
echo [29] Plano de energia
echo ----------------------------------------
powercfg /getactivescheme
echo.
echo [1] Alto desempenho
echo [2] Desempenho maximo (Ultimate)
echo [3] Equilibrado (padrao)
echo [0] Voltar
set "pl="
set /p "pl=Opcao: "
if "%pl%"=="1" powercfg /setactive SCHEME_MIN || echo Plano indisponivel neste equipamento.
if "%pl%"=="2" (
    for /f "tokens=4" %%G in ('powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61') do powercfg /setactive %%G
)
if "%pl%"=="3" powercfg /setactive SCHEME_BALANCED
if not "%pl%"=="0" ( call :LOG "Plano de energia %pl%" & powercfg /getactivescheme & pause )
goto MENU

:EXP_30
call :INFO "[30] Otimizar unidades" "TRIM em SSD e desfragmentacao em HD, detectado automaticamente." "1 a 30 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :LOG "defrag /C /O"
defrag /C /O /U /V
pause
goto MENU

:EXP_31
call :INFO "[31] Limpeza WinSxS" "Remove versoes antigas de componentes do Windows Update." "5 a 15 min" "Nao"
if not "%escolha%"=="1" goto MENU
call :LOG "DISM StartComponentCleanup"
dism /online /cleanup-image /startcomponentcleanup
pause
goto MENU

:EXP_32
call :INFO "[32] Programas na inicializacao" "Lista os programas que iniciam com o Windows e abre o Gerenciador de Tarefas." "Instantaneo" "Nao"
if not "%escolha%"=="1" goto MENU
powershell -NoProfile -Command "Get-CimInstance Win32_StartupCommand | Select-Object Name,Location | Format-Table -AutoSize"
echo Desative os desnecessarios na aba Inicializar.
start "" taskmgr /0 /startup
pause
goto MENU

:EXP_33
call :INFO "[33] Saude dos discos" "Tipo SSD/HDD, estado SMART e desgaste." "Instantaneo" "Nao"
if not "%escolha%"=="1" goto MENU
powershell -NoProfile -Command "Get-PhysicalDisk | ForEach-Object { $r=$_ | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue; [pscustomobject]@{Disco=$_.FriendlyName; Tipo=$_.MediaType; Saude=$_.HealthStatus; TempC=$r.Temperature; Desgaste=$r.Wear; HorasLigado=$r.PowerOnHours} } | Format-Table -AutoSize"
pause
goto MENU

:EXP_34
call :INFO "[34] Efeitos visuais" "Abre as opcoes de desempenho. Escolha Ajustar para melhor desempenho." "Instantaneo" "Nao"
if "%escolha%"=="1" start "" SystemPropertiesPerformance.exe
goto MENU

:EXP_35
call :INFO "[35] Hibernacao" "Desativa a hibernacao e remove o hiberfil.sys, liberando GBs. Desativa a Inicializacao
