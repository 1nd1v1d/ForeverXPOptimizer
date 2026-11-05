# Forever XP Optimizer 0.1.0

WoW Forever, Interface 16001, deutsche Oberfläche. Keine weiteren Addons erforderlich.

Kompakte XP-Leiste: Lila = aktuelle XP, Gold = abgabefertige Quest-XP, Blau = Erholungsvorrat. Die Questzeile zeigt die vorgemerkte XP-Summe sowie Level und Prozent nach sofortiger Abgabe. Tooltip über der Leiste: einzelne Quests und Belohnungen. Unvollständige Daten sind gekennzeichnet. Quest-XP werden erst nach tatsächlicher Abgabe als verdient gezählt. Die Vorschau verwendet aktuelle Belohnungen; Abgabereihenfolge, Buffwechsel und neue Level können sie verändern.

Nach der Installation WoW starten beziehungsweise neu starten und das Addon im AddOns-Menü aktivieren. Nach Updates eines bereits geladenen Addons genügt /reload.

/fxp öffnet die Anzeige. Linksklick am Hintergrund verschiebt das Fenster, Rechtsklick öffnet Details. Die Häkchen schalten Quellen einzeln aus. Details enthalten Stufenvorschau und Levelverlauf.

Befehle:

- /fxp hide – Fenster ausblenden
- /fxp pause – aktive Messung pausieren/fortsetzen
- /fxp neu – neue Sitzung; Levelverlauf bleibt erhalten
- /fxp ton – optionalen Hinweiston umschalten
- /fxp scale 0.9 – Fenstergröße ändern
- /fxp warn 60 – Vorwarnung in Sekunden
- /fxp level 14 und /fxp live – Stufenvorschau / aktuelle Stufe
- /fxp diagnose – Build und Datenlesbarkeit anzeigen, Spielzeit neu anfragen
- /fxp position – Position zurücksetzen

AFK wird separat gezählt und aus Rate und Prognose herausgerechnet. Der Tracker verwendet den vom Spiel gemeldeten AFK-Status. Eine manuelle Pause stoppt sowohl XP- als auch Zeitmessung für die Rate. Gesamtspielzeit enthält AFK; alte AFK-Zeiten sind nicht rückwirkend rekonstruierbar.

Rate: letzte 15 aktive Minuten, mindestens zwei Minuten Messbasis. Level-up wird in aktiver Spielzeit geschätzt. Nach längeren Pausen werden frische Daten gesammelt. Daten werden bei WoW-Logout beziehungsweise /reload gespeichert.

Bei eingeschränkten Aura-Daten steht „unbekannt“ statt einer Fehlwarnung. Nicht jeder Satt-Buff erhöht XP. Unbekannte Satt-Auren lassen sich durch erneutes Essen eines anhand des Tooltips bestätigten XP-Gerichts zuordnen. Bei einem Client-Buildwechsel werden solche gelernten Zuordnungen erneut geprüft. Zelt-Aufstellabklingzeit und persönliche Bezugssperre sind getrennte Bedingungen. Legacy wird als dauerhafte Verbesserung erläutert, ohne unprüfbare Ränge vorzutäuschen.

Entwicklung und Quellen: Projekt Forver_XP_Optimizer, KONZEPT.md und README.md. Automatisch mit Lua 5.1 getestet; bei Auslieferung noch kein angemeldeter Ingame-Test.
