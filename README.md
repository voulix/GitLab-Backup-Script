### Token Setup

- Account Token mit Read Permissions erstellen
- Die folgenden Optionen müssen dabei ausgewählt sein:

```yml
1. read_user
2. read_repository
3. read_virtual_registry
4. read_registry
5. read_api
6. api
```

### Skript Setup

- In der Datei backup-gitlab.ps muss man vorher noch einige Sachen definieren, dort gibt es oben diesen Abschnitt:

```ps1
# =================== CONFIGURATION ===================
$GITLAB_HOST   = "gitlab.deinedomain.de"                 # GitLab server without http(s)://
$GITLAB_TOKEN  = "hierbittedeinaccounttoken"            # Personal Access Token with read_api + read_repository
$PREFIX        = "C:\Pfad\Zum\Speichern\des\Backups"    # Target folder for backups
$EXCLUDE_REPOS = ""                                     # Leave empty to backup all
$FETCH_PROTO   = "https"                                # Using HTTPS + token or SSH + no token
$GITLAB_USER   = "git"                                  # User for HTTPS URLs
# ======================================================
```

> ``` $GITLAB_HOST = "gitlab.uni-kassel.de" ``` Dort muss man die GitLab Server Domain ohne **HTTPS/HTTP** angeben.

> ``` $GITLAB_TOKEN = "hierbittedeinaccounttoken" ``` Hier den Account Token einfügen, der im Schritt **Token Setup** erstellt wurde.

> ``` $PREFIX = "C:\Pfad\Zum\Speichern\des\Backups" ``` Hier den Pfad angeben, an dem das Backup gespeichert werden soll.

> ``` $PREFIX = "$EXCLUDE_REPOS = "" ``` Hier Repos im Format ```"repo1|repo2"``` angeben, die vom Backup ausgeschlossen werden sollen.

> ``` $FETCH_PROTO   = "https"" ``` Hier angeben, wie man den Server anspricht: HTTPS, HTTP, SSH (dafür muss ein entsprechendes Zertifikat auf dem Server liegen).

> ``` $GITLAB_USER   = "git" ``` Git für HTTPS/HTTP für SSH zu dem User ändern, der sich einloggen soll.

### Auführung

>- Zum Starten müssen beide Dateien ```backup_start.bat``` und ```backup-gitlab.ps1``` im selben Ordner liegen.
>- Dann die ```backup_start.bat``` ausführen, fertig :)

>- Alternativ den Command ```powershell -ExecutionPolicy Bypass -File .\backup-gitlab.ps1``` zum Ausführen nutzen.