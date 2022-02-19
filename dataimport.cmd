@ECHO OFF

SETLOCAL
set dt=log\%DATE:~6,4%_%DATE:~3,2%_%DATE:~0,2%

if not exist log\ (
	mkdir log
)

ECHO  %DATE% - %TIME% - Iniciando dataimport SOLR
ECHO  %DATE% - %TIME% - Iniciando dataimport SOLR >> %dt%.log

SET URL="http://localhost:8983/solr/Teste/dataimport?command=full-import&clean=false"
SET URLSTATUS="http://localhost:8983/solr/Teste/dataimport?command=status"

SET retries=0

:request
	ECHO  %DATE% - %TIME% - Inicando indexacao em %URL%
	ECHO  %DATE% - %TIME% - Inicando indexacao em %URL% >> %dt%.log

	for /f %%a in ( 'curl -s -o %dt%_request.log -w "%%{http_code}" %URL%') do set "http_code=%%a"

	ECHO  %DATE% - %TIME% - Retorno chamada indexacao - HTTP_CODE: %http_code%
	ECHO  %DATE% - %TIME% - Retorno chamada indexacao - HTTP_CODE: %http_code% >> %dt%.log

	if %http_code% == 200 GOTO checkstatus
	
	ECHO  %DATE% - %TIME% - TIMEOUT - Aguardando 1 minuto para nova tentativa de indexacao
	ECHO  %DATE% - %TIME% - TIMEOUT - Aguardando 1 minuto para nova tentativa de indexacao >> %dt%.log
	TIMEOUT 60

	if %retries% LEQ 2 (
		SET /A retries+=1
		ECHO  %DATE% - %TIME% - Reiniciando tentativa de indexacao
		ECHO  %DATE% - %TIME% - Reiniciando tentativa de indexacao >> %dt%.log
		GOTO request
	) else (
		ECHO  %DATE% - %TIME% - Nao foi possivel conectar ao servidor - HTTP_CODE: %http_code%
		ECHO  %DATE% - %TIME% - Nao foi possivel conectar ao servidor - HTTP_CODE: %http_code% >> %dt%.log
		exit /b 1
	)


SET retries=0

:checkstatus

	if %retries% LEQ 100 (
		SET /A retries+=1
	) else (
		ECHO  %DATE% - %TIME% - Nao foi possivel verificar o estado - %retries% tentativas realizadas
		ECHO  %DATE% - %TIME% - Nao foi possivel verificar o estado - %retries% tentativas realizadas >> %dt%.log
		exit /b 1
	)

	ECHO  %DATE% - %TIME% - Verificando estado da indexacao em %URLSTATUS%
	ECHO  %DATE% - %TIME% - Verificando estado da indexacao em %URLSTATUS% >> %dt%.log
	for /f %%a in ( 'curl -s %URLSTATUS% ^| FIND /I "idle"' ) do set "STATUS=%%a"

	if defined STATUS (
		SET ESTADO="concluido"
	) else (
		SET ESTADO="processando"
	)

	ECHO  %DATE% - %TIME% - Estado eh: %ESTADO%
	ECHO  %DATE% - %TIME% - Estado eh: %ESTADO% >> %dt%.log

	if %ESTADO% == "processando" (
		ECHO  %DATE% - %TIME% - Aguardando 1 minuto para nova verificacao - %retries% tentativas
		ECHO  %DATE% - %TIME% - Aguardando 1 minuto para nova verificacao - %retries% tentativas >> %dt%.log
		TIMEOUT 60
		GOTO checkstatus
	) else (
		ECHO  %DATE% - %TIME% - indexacao finalizada - estado - %ESTADO%
		ECHO  %DATE% - %TIME% - indexacao finalizada - estado - %ESTADO% >> %dt%.log
		ECHO ====================================================================================== >> %dt%.log
		ECHO ================================RESULTADO DA INDEXACAO================================ >> %dt%.log
		curl -s %URLSTATUS% >> %dt%.log 
		ECHO ====================================================================================== >> %dt%.log
		ECHO: >> %dt%.log
	)
