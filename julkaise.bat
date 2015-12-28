git pull
git add .
git commit -m "julkaise.bat"

IF "%JOLTE_USERNAME%" <> "" IF "%PASSWORD%" <> "" GOTO SET

:NOT_SET
git push
GOTO END

:SET
git push --repo https://%JOLTE_USERNAME%:%JOLTE_PASSWORD%@github.com/perttitaneli/jolte.git
GOTO END

:END
