git pull
git add .
git commit -m "julkaise.bat"

REM IF EXISTS "%JOLTE_USERNAME%" IF EXISTS "%JOLTE_PASSWORD%" GOTO SET

REM :NOT_SET
REM git push
REM GOTO END

:SET
git push --repo https://%JOLTE_USERNAME%:%JOLTE_PASSWORD%@github.com/perttitaneli/jolte.git
GOTO END

:END
