git pull
git add .
git commit -m "julkaise.bat"

IF EXISTS "%JOLTE_USERNAME%" IF EXISTS "%JOLTE_PASSWORD%" GOTO SET

:NOT_SET
git push
GOTO END

:SET
git push --repo https://%JOLTE_USERNAME%:%JOLTE_PASSWORD%@github.com/perttitaneli/jolte.git
GOTO END

:END
