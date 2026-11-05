<p align="center">
  <img src="assets/logo.png" alt="Forever XP Optimizer – goldenes Unendlichkeitszeichen mit violetter XP-Leiste" width="220">
</p>

# Forever XP Optimizer

**Dein Level-Fortschritt, deine XP-Boni und dein nächster Stufenaufstieg auf einen Blick.**

Forever XP Optimizer verbindet eine kompakte XP-Leiste mit Buff-Erinnerungen und einem Spielzeit-Tracker für **World of Warcraft: Forever**. Du siehst, welche XP-Vorteile dir auf deiner Stufe fehlen, wie schnell du aktiv levelst und welchen Fortschritt dir die Abgabe bereits fertiger Quests bringen würde. AFK-Zeit wird separat angezeigt und aus XP/Stunde sowie der Level-up-Prognose herausgerechnet.

- **XP-Boni im Blick:** Essen, Schlafsack, Erholung, Lagerzelt und situative Gegenstände; optionale Quellen einzeln abschaltbar.
- **Rechtzeitig erinnert:** Hinweise auf fehlende, unvollständige und bald auslaufende Buffs.
- **Quest-XP vorausplanen:** Goldene Vorschau für abgabefertige Quests, einschließlich möglicher Stufenaufstiege.
- **Aktive Levelgeschwindigkeit:** XP/Stunde über die letzten 15 aktiven Minuten und geschätzte Zeit bis zum nächsten Level.
- **Spielzeiten nachvollziehen:** Gesamtspielzeit, Sitzung, Zeit pro Level und gespeicherter Verlauf mit eigener AFK-Erfassung.
- **Schlanke Installation:** Deutsche Oberfläche, verschiebbar und skalierbar, ohne erforderliche Zusatzaddons.

Entwickelt für Interface **16001**. Letzter lokal geprüfter Installationsbuild: **1.60.1.70790**. Der aktuelle Stand ist eine erste, automatisch getestete Version; die Grenzen der Ingame-Prüfung stehen weiter unten.

Die Hauptanzeige enthält Level- und Sitzungszeit, aktuelle/benötigte/verbleibende XP, Prozentanzeige, XP/Stunde, Level-up-Prognose und Buffsymbole. Gold zeigt vorgemerkte XP aus abgabefertigen Quests. Daneben stehen die XP-Summe sowie Level und Fortschritt nach sofortiger Abgabe. Einzelne Questbelohnungen erscheinen im Tooltip der Leiste und in den Details. Fehlende Questdaten werden als unbekannt beziehungsweise Untergrenze gekennzeichnet.

Quest-XP stammen aus `GetQuestLogRewardXP(questID)` und werden nicht zusätzlich mit angenommenen Buffwerten multipliziert. Die Vorschau nutzt aktuelle Belohnungen und die 1–60-XP-Kurve; Abgabereihenfolge, veränderte Buffs oder bereits erreichte Level können spätere Belohnungen verändern. Noch nicht abgegebene XP zählen nicht zur gemessenen Rate.

## Benutzung

Den Ordner `ForeverXPOptimizer` in den Addon-Ordner deines Forever-Clients kopieren:

```text
World of Warcraft/_forever_/Interface/AddOns/ForeverXPOptimizer/
```

Die Datei `ForeverXPOptimizer.toc` muss unmittelbar in diesem Ordner liegen. WoW starten oder neu starten und im Charakterauswahlbildschirm unter **AddOns** „Forever XP Optimizer“ aktivieren. Bei bereits geladenem Addon genügt nach einem Update `/reload`.

- `/fxp` öffnet das Fenster; `/fxp hide` blendet es aus.
- Linke Maustaste am Hintergrund: Fenster verschieben. Rechtsklick oder **Details**: Quellen, Stufenvorschau und Levelverlauf.
- Die Häkchen links schalten jede Quelle einzeln ein oder aus.
- **Pause** hält die aktive Messung an; **Neue Sitzung** setzt nur Sitzungswerte und die aktuelle Rate zurück.
- `/fxp scale 0.9` stellt die Größe ein; `/fxp position` setzt die Position zurück.
- `/fxp warn 60` stellt die Ablauf-Vorwarnung in Sekunden ein.
- `/fxp ton` schaltet den optionalen Hinweiston um.
- `/fxp level 14` zeigt die Quellenvorschau für eine Stufe; `/fxp live` kehrt zur aktuellen Stufe zurück.
- `/fxp diagnose` zeigt Build, Interface und Lesbarkeit im Chat an und fragt `/played` neu an.
- `/fxp quelle food` schaltet beispielsweise Essen um. Weitere Schlüssel: `sleep`, `rested`, `tent`, `pendant`, `legacy`.

Das Fenster startet nach dem Login mit 15 Sekunden Schonfrist für Hinweise. Warnungen werden während Kampf, Tod, AFK und manueller Pause unterdrückt und danach neu bewertet. Beschaffungshinweise erscheinen einmal pro Zustandswechsel, reguläre Erinnerungen höchstens alle fünf Minuten. Die Grundvorwarnung beträgt 60 Sekunden.

## Was erfasst wird

- Geeignetes XP-Essen: verifizierte Basisgerichte plus Erkennung weiterer Speisen anhand ihres aktuellen XP-Tooltips.
- Schlafsack: echte Aura-Restzeit, Stapel und Gegenstandsabklingzeit.
- Erholungs-XP und Lagerzelt: Erholungsvorrat, 5-%-Grenze, Aufstellabklingzeit; persönliche Sperre nur bei entsprechender lesbarer Aura.
- Untoten-Anhänger ab Stufe 30: Erinnerung bei Besitz und Untotem im Ziel.
- Legacy: Hinweise auf relevante dauerhafte Vorteile. Auswahl und Ränge werden im Legacy-Menü geprüft.
- Gesamte Charakterspielzeit, aktuelle Stufenspielzeit, Sitzung, gemessene aktive Zeit, AFK und manuelle Pause.
- Tatsächlich erhaltene XP je aktiver Stunde über die letzten 15 aktiven Minuten; Prognose nach mindestens zwei aktiven Messminuten.
- Persistenter Levelverlauf, getrennt je stabiler Charakter-ID. `/reload` erhält die Sitzungszähler; eine neue Anmeldung beginnt eine neue Sitzung. Die kurzfristige Rate sammelt nach einem Reload frische Daten.

AFK ist der vom Spiel gemeldete AFK-Status. Die Wartezeit vor diesem Status kann das Addon nicht nachträglich als AFK erkennen. Für andere Pausen gibt es die manuelle Pause. Während AFK oder manueller Pause erhaltene XP fließen nicht in die aktive Rate ein. Offlinezeit zählt nicht als Spielzeit oder AFK.

## Grenzen und Live-Prüfung

Die Quellen und das Konzept stehen in [KONZEPT.md](KONZEPT.md). Die Implementierung wurde mit einer echten Lua-5.1-Laufzeit und einer simulierten modernen WoW-API geprüft. Ein angemeldeter Ingame-Test wurde bei der Auslieferung noch nicht durchgeführt.

Forever kann Aura-Daten insbesondere im Kampf oder in Instanzen einschränken. Dann steht **unbekannt/eingeschränkt** anstelle einer Fehlwarnung. Ein unbekannter „Satt“-Buff wird nicht pauschal als XP-Buff behandelt: Nach dem erneuten Essen einer bestätigten XP-Speise kann das Addon die tatsächlich neu erhaltene beziehungsweise erneuerte Satt-Aura zuordnen. Diese Zuordnung gilt nur für den beobachteten Client-Build. Zwei verifizierte sichtbare Forever-Essensauren und der direkte XP-Effekt sind bereits hinterlegt.

Die Schlafsack-Dauer wird nicht fest auf eine oder zwei Stunden gesetzt. Event-Buffs aus Retail/SoD werden nicht allein aufgrund alter Daten als EU-Forever-Quelle gemeldet. Studentenfutter enthält in Forever keinen Erholungsbonus. Eine fertige Zelt-Aufstellabklingzeit beweist keinen erneuten persönlichen Bezugsanspruch; das Addon behauptet deshalb ohne lesbare Sperrinformation auch keinen garantierten Anspruch.

Gesamtspielzeit und aktuelle Stufenspielzeit stammen aus der `/played`-Antwort. Alte AFK-Zeiten und bereits vor Installation abgeschlossene Level werden nicht erfunden. Bei einer Teilaufzeichnung ist die aktive/AFK-Aufteilung nur für den tatsächlich gemessenen Anteil bekannt. Bei extrem großen einzelnen XP-Belohnungen kann eine Stufe innerhalb eines Ereignisses übersprungen werden; der Verlauf kennzeichnet das ausdrücklich.

## Entwicklung und Prüfung

Keine Laufzeitabhängigkeiten, keine Netzwerkzugriffe im Addon und keine automatische Nutzung von Gegenständen.

```powershell
$env:UV_CACHE_DIR = Join-Path (Get-Location) '.tools\uv-cache'
uv pip install --target .tools\python lupa==2.6
python tools/run_tests.py
.tools\stylua.exe --check ForeverXPOptimizer tests
```

Testwerkzeug: **Lupa 2.6**, Modul `lupa.lua51` (Lua 5.1). Formatter: **StyLua 2.6.0**, Konfiguration in `.stylua.toml`. Beide bleiben Entwicklungswerkzeuge in `.tools`; sie sind nicht Bestandteil der Addon-ZIP. Für dieses neue Projekt waren kein bestehender Linter, Typechecker oder Semgrep installiert. Lua-Dateien werden mit Lua 5.1 kompiliert; die relevanten Regeln und der tatsächliche Ereignis-/UI-Code laufen in den automatisierten Tests.

## Paket und Installation

```powershell
powershell -ExecutionPolicy Bypass -File tools/deploy.ps1
```

Das Skript prüft Produktkennung `wowf`, kopiert ausschließlich die Dateien dieses Addons, sichert eine vorhandene Installation unter `dist/backups` im Projekt und vergleicht anschließend SHA-256-Prüfsummen. Andere Addons und WoW-Einstellungen werden nicht verändert. Eine ZIP und ein Installationsbericht werden unter `dist` erzeugt.

Technische Grundlage: die [Forever-API-Quelldokumentation](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated), insbesondere `UnitAuraDocumentation.lua`, `ItemDocumentation.lua`, `PlayerScriptDocumentation.lua` und `SecretPredicateAPIDocumentation.lua`.

Projektbeschreibung zur Weiterverwendung: [docs/BESCHREIBUNG.md](docs/BESCHREIBUNG.md). Logo und Gestaltungsbriefing: [docs/BRANDING.md](docs/BRANDING.md).
