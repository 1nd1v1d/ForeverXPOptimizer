# Forever XP Optimizer

## Kurzbeschreibung

WoW-Forever-Addon mit XP-Buff-Erinnerungen, aktiver XP/Stunde, separater AFK-Erfassung, Levelzeiten und Vorschau für abgabefertige Quest-XP.

## Projektbeschreibung

**Leveln mit Überblick:** Forever XP Optimizer zeigt dir deinen Fortschritt und die passenden XP-Vorteile für deine aktuelle Stufe in einer kompakten, frei verschiebbaren Anzeige.

Behalte XP-Essen, Schlafsack und Erholung im Blick und lass dich an fehlende oder auslaufende Boni erinnern. Eine aufklappbare Übersicht erläutert Voraussetzungen und relevante Gegenstände. Optionale Quellen lassen sich einzeln abschalten.

Der integrierte Tracker zeigt Gesamtspielzeit, Sitzungszeit, Spielzeit pro Level und deine aktuelle Levelgeschwindigkeit. AFK-Zeiten werden separat erfasst und aus XP/Stunde und der Prognose bis zum nächsten Stufenaufstieg herausgerechnet. Ein gespeicherter Verlauf macht deine gemessenen Levelzeiten nachvollziehbar.

Bereits erledigte Quests sind als goldene Vorschau auf der XP-Leiste sichtbar. Du siehst ihre bekannte XP-Summe und welches Level samt Fortschritt du bei sofortiger Abgabe erreichen würdest. Auch mehrere mögliche Stufenaufstiege werden berücksichtigt. Die vorgemerkten Quest-XP zählen erst nach der tatsächlichen Abgabe zur gemessenen Levelgeschwindigkeit.

Die deutsche Oberfläche kommt ohne erforderliche Zusatzaddons aus. Position, Größe, Vorwarnzeit und Hinweiston sind anpassbar. Mit `/fxp` öffnest du die Anzeige; per Rechtsklick erreichst du Details und den Levelverlauf.

## Aktueller Entwicklungsstand

Erste Version für den offiziellen WoW-Forever-Client, Interface 16001. Mit Lua 5.1, 24 Regeltests und einem Testlauf für Ereignisanbindung und Oberfläche automatisch geprüft. Ein angemeldeter Ingame-Test steht noch aus.

Bei eingeschränkten Aura-Daten meldet das Addon einen unbekannten Status. Legacy-Vorteile werden erläutert; ihre gewählten Ränge werden im Spielmenü geprüft. Questprognosen verwenden die aktuellen Client-Belohnungen und können sich mit Buffs, Level oder Abgabereihenfolge ändern. Historische AFK-Zeiten vor Beginn der Aufzeichnung werden nicht nachträglich geschätzt.
