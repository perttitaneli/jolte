git pull
git add .
git commit -m "julkaise.bat"

@IF NOT "%JOLTE_USERNAME%" == "" IF NOT "%JOLTE_PASSWORD%" == "" GOTO SET

:NOT_SET
git push
@GOTO END

:SET
git push --repo https://%JOLTE_USERNAME%:%JOLTE_PASSWORD%@github.com/perttitaneli/jolte.git
@GOTO END

:END

@pause