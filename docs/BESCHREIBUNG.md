# Forever XP Optimizer

## Kurzbeschreibung

Sieh auf einen Blick, welche XP-Booster dir auf deiner Stufe fehlen, und erhalte Erinnerungen an auslaufende Buffs – mit aktivem XP-Tracker und Quest-XP-Vorschau.

## Projektbeschreibung

**Leveln mit Überblick:** Forever XP Optimizer zeigt dir deinen Fortschritt und die passenden XP-Vorteile für deine aktuelle Stufe in einer kompakten, frei verschiebbaren Anzeige.

Behalte XP-Essen, Schlafsack und Erholung im Blick und lass dich an fehlende oder auslaufende Boni erinnern. Eine aufklappbare Übersicht erläutert Voraussetzungen und relevante Gegenstände. Optionale Quellen lassen sich einzeln abschalten.

Der integrierte Tracker zeigt Gesamtspielzeit, Sitzungszeit, Spielzeit pro Level und deine aktuelle Levelgeschwindigkeit. AFK-Zeiten werden separat erfasst und aus XP/Stunde und der Prognose bis zum nächsten Stufenaufstieg herausgerechnet. Ein gespeicherter Verlauf macht deine gemessenen Levelzeiten nachvollziehbar.

Bereits erledigte Quests sind als goldene Vorschau auf der XP-Leiste sichtbar. Du siehst ihre bekannte XP-Summe und welches Level samt Fortschritt du bei sofortiger Abgabe erreichen würdest. Auch mehrere mögliche Stufenaufstiege werden berücksichtigt. Die vorgemerkten Quest-XP zählen erst nach der tatsächlichen Abgabe zur gemessenen Levelgeschwindigkeit.

Die Oberfläche passt sich automatisch der WoW-Textsprache an: Deutsch, Englisch, Französisch, Spanisch, Italienisch, Portugiesisch, Russisch, Koreanisch sowie vereinfachtes und traditionelles Chinesisch. Regionale Varianten verwenden die gemeinsame Basissprache, Englisch dient als Fallback. Es sind keine Zusatzaddons oder Übersetzungsdienste nötig. Position, Größe, Vorwarnzeit und Hinweiston sind anpassbar. Mit `/fxp` öffnest du die Anzeige; per Rechtsklick erreichst du Details und den Levelverlauf.

## Aktueller Entwicklungsstand

Version 0.2.0 für den offiziellen WoW-Forever-Client 1.60.1, Interface 16001. Mit Lua 5.1, 24 Regeltests, Übersetzungsprüfungen und vollständigen Ereignis-/UI-Testläufen für alle unterstützten Sprachen, regionale Aliasse und Englisch-Fallback automatisch geprüft. Ein angemeldeter Ingame-Test und eine muttersprachliche Prüfung aller Übersetzungen stehen noch aus.

Die englische Fassung für die CurseForge-Projektseite steht in [CURSEFORGE.md](CURSEFORGE.md).

Bei eingeschränkten Aura-Daten meldet das Addon einen unbekannten Status. Legacy-Vorteile werden erläutert; ihre gewählten Ränge werden im Spielmenü geprüft. Questprognosen verwenden die aktuellen Client-Belohnungen und können sich mit Buffs, Level oder Abgabereihenfolge ändern. Historische AFK-Zeiten vor Beginn der Aufzeichnung werden nicht nachträglich geschätzt.
