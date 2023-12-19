@echo    *****************************************
@echo    ***  DELETANDO E ALTERANDO DIRETORIO  ***
@echo    ***   DE ARQUIVOS DO WINDOWS UPDATE   ***
@echo    *****************************************

@echo PARANDO O SERVICO WINDOWS UPDATE
net stop wuauserv

@echo PARANDO O SERVICO BITS
net stop bits

@echo DELETANDO O DIRETORIO DE ARQUIVOS DO WINDOWS UPDATE
if exist C:\Windows\SoftwareDistribution rmdir /S /Q C:\Windows\SoftwareDistribution

@echo CRIANDO O NOVO DIRETORIO DE ARQUIVOS DO WINDOWS UPDATE
if not exist D:\SoftwareDistribution mkdir D:\NovaPastaAtualizacoes

@echo CRIANDO UM LINK SIMBOLICO PARA O NOVO DIRETORIO DE ARQUIVOS DO WINDOWS UPDATE
CD /D C:\Windows
mklink /J SoftwareDistribution D:\NovaPastaAtualizacoes

@echo INICIANDO O SERVICO WINDOWS UPDATE
net start wuauserv

@echo INICIANDO O SERVICO BITS
net start bits

pause

:: OBS: O script deve ser executado como Administrador no Windows
