# Forever XP Optimizer – Konzept

Stand: 05.11.2026. Ziel: offizielles WoW Forever, EU-Live, deutscher Client.

Umsetzungsergänzung: Die vom Nutzer gelieferte Bildvorlage legt eine kompakte horizontale XP-Leiste fest. Abgabefertige Quests werden mit ihrer aktuellen Client-XP-Belohnung summiert und als goldene Vorschau angezeigt; zusätzliche Anzeige des Levels und Fortschritts nach Abgabe, einschließlich mehrerer möglicher Stufenaufstiege. Buffdetails und Verlauf bleiben aufklappbar. Vorgemerkte XP beeinflussen die gemessene Rate erst bei tatsächlichem Erhalt.

Dieses Dokument beschreibt Recherche, Verhalten und Abnahmekriterien. Es ist noch keine Addon-Implementierung. Der Projektordner war bei der Bestandsaufnahme leer.

## 1. Festgelegte Anforderungen

- Für jede Charakterstufe die aktuell erreichbaren XP-Vorteile und fehlenden Voraussetzungen anzeigen.
- Alle erreichbaren Quellen standardmäßig berücksichtigen; jede optionale Quelle einzeln abschaltbar.
- Fehlende, unvollständige und auslaufende Buffs erkennen und mit einer konkreten Handlung verknüpfen.
- Gesamtspielzeit, Spielzeit pro Stufe, aktuelle XP/Stunde und voraussichtlichen Stufenaufstieg anzeigen.
- AFK-Zeit getrennt ausweisen und aus XP/Stunde sowie Prognose herausrechnen.
- Deutsche Oberfläche; Gegenstandsnamen möglichst aus dem Client laden. Englische Namen unten dienen als eindeutige Recherchebezeichnungen.

## 2. Recherche und Verlässlichkeit

Der EU-Start liegt am 05.11.2026 um 00:00 MEZ. Viele verfügbare Guides beruhen noch auf der Beta. Deshalb unterscheidet das Addon offiziell beschriebene Systeme, in Forever berichtete Funde und reine Datenbankeinträge. Die Recherche ersetzt keinen Test im aktuellen Live-Client. [Blizzard, deutsche Neuigkeiten](https://worldofwarcraft.blizzard.com/de-de/news)

### Direkte XP-Boni und Erholung

| Quelle | Wirkung | Zugang / relevante Gegenstände | Umsetzung |
| --- | --- | --- | --- |
| Well Fed XP Boost | +5 % XP aus Gegnerkills laut Tooltip | Geeignete gekochte Speisen; erste Optionen ohne ausgewiesene Charakterstufenanforderung | Eine erfüllbare Kategorie „XP-Buff-Food“, mit Restlaufzeit und Vorrat |
| Cozy Sleeping Bag | Je eine Minute Ruhen ergibt einen Stapel; maximal drei Stapel mit insgesamt +3 % Erfahrung | Gegenstand 211527; eigene Questreihe ab Stufe 14 | Beschaffungshinweis, 0–3 Stapel, echte Restlaufzeit und Gegenstandsabklingzeit |
| Reguläre Erholungs-XP | Erholungsvorrat erhöht Kill-XP, bis er verbraucht ist | Gasthäuser/Ruhezonen und Offline-Erholung | Vorrat in XP und relativ zur aktuellen Stufe; keine erfundene Ablaufzeit |
| Camp Tent | Füllt den Erholungsvorrat auf 5 % einer Stufe auf; kein Vorteil, wenn bereits mehr vorhanden ist | Gegenstand 279978; Aufstellen erfordert Lederverarbeitung 20 und Lagerfeuer. Andere Spieler können profitieren. | Vorrat, persönliche Bezugssperre und Aufstellabklingzeit getrennt behandeln |
| Archmagister's Faceted Pendant | +10 % XP aus Untotenkills für 5 Minuten; Grundabklingzeit 6 Stunden | Gegenstand 273049; tragbar ab Stufe 30; Datenbank nennt Shade of the Archmage als Beutequelle | Situative Quelle; bei Besitz und passendem Kontext hervorheben, als Beschaffung optional anzeigen |

Quellen: [Well Fed, Effektbeschreibung](https://www.wowhead.com/forever/spell=1243969/well-fed-xp-boost), [Schlafsack-Fundbericht](https://www.wowhead.com/ptr/news/cozy-sleeping-bag-is-back-in-wow-forever-383000), [Schlafsack-Guide](https://www.warcrafttavern.com/forever/guides/cozy-sleeping-bag/), [Erfahrung und Erholung](https://www.warcrafttavern.com/forever/guides/experience/), [Blizzard: Camping](https://worldofwarcraft.blizzard.com/en-us/news/24301516/gather-around-the-campfire-in-world-of-warcraft-forever), [Camp Tent: Gegenstand](https://www.wowhead.com/forever/item=279978/camp-tent), [Anhänger: Gegenstand](https://www.wowhead.com/forever/item=273049/archmagisters-faceted-pendant).

Die Schlafsack-Dauer ist widersprüchlich beschrieben: Ein Wowhead-Guide nennt eine Stunde, andere Forever-Berichte zwei Stunden. Die Gegenstandsabklingzeit wird mit einer Stunde angegeben. Außerdem trägt die Wowhead-Gegenstandsseite trotz Fundberichten noch einen Hinweis auf unbestätigte Verfügbarkeit. Im Addon gelten daher beobachtete Aura-Dauer und Live-Quest-/Besitzstatus; die Beschaffung bleibt bis zur Live-Prüfung als berichtet markiert. Die eigene Questreihe ab 14 und das mögliche Mitbenutzen eines Gruppenschlafsacks sind unterschiedliche Voraussetzungen. [Wowhead-Guide](https://www.wowhead.com/forever/guide/cozy-sleeping-bag-locations-rewards), [Gegenstandsseite und Kommentare](https://www.wowhead.com/forever/item=211527/cozy-sleeping-bag).

Beim Zelt sind eine ungefähr einstündige persönliche Bezugssperre und die gemeinsame Aufstellabklingzeit von Campingobjekten zu unterscheiden. Eine fertige Aufstellabklingzeit beweist keinen neuen persönlichen Erholungsanspruch. Die genaue Wartezeit am Zelt wird aus dem Spielzustand abgeleitet; Datenbank und allgemeine Campingbeschreibungen nennen unterschiedliche Zeitangaben. [Zelt-Bezugseffekt](https://www.wowhead.com/forever/spell=1229487/camp-tent), [Aufstelleffekt](https://www.wowhead.com/forever/spell=1307230/camp-tent).

### Konkrete Buff-Food-Auswahl

Alle folgenden Speisen nennen im Forever-Tooltip zusätzlich +5 % Kill-XP. Die Zusatzattribute unterscheiden sich; teureres Essen ist für den XP-Anteil allein nicht automatisch besser. Die erste Spalte bezeichnet die Nutzungsstufe des Charakters, nicht Gegenstandsstufe oder Kochfertigkeit.

| Nutzungsstufe | Gegenstand | ID | Zusätzlicher Nutzen laut aktuellem Datenbanktooltip |
| --- | --- | --- | --- |
| Keine ausgewiesen | [Brilliant Smallfish](https://www.wowhead.com/forever/item=6290/brilliant-smallfish) | 6290 | 2 Angriffskraft |
| Keine ausgewiesen | [Herb Baked Egg](https://www.wowhead.com/forever/item=6888/herb-baked-egg) | 6888 | 1 Ausdauer |
| Keine ausgewiesen | [Crispy Bat Wing](https://www.wowhead.com/forever/item=12224/crispy-bat-wing) | 12224 | 1 Intelligenz |
| Keine ausgewiesen | [Spiced Wolf Meat](https://www.wowhead.com/forever/item=2680/spiced-wolf-meat) | 2680 | 1 Beweglichkeit |
| 10 | [Smoked Sagefish](https://www.wowhead.com/forever/item=21072/smoked-sagefish) | 21072 | 4 Zauberschaden |
| 35 | [Monster Omelet](https://www.wowhead.com/forever/item=12218/monster-omelet) | 12218 | 15 Ausdauer |
| 35 | [Nightfin Soup](https://www.wowhead.com/forever/item=13931/nightfin-soup) | 13931 | 22 Zauberschaden |

Diese Tooltips verlangen jeweils mindestens 10 Sekunden Essen für den Buff und nennen eine Grunddauer von 15 Minuten. Das Addon verwendet die tatsächliche Dauer einschließlich möglicher Verlängerungen. Die Auswahl ist ein geprüfter Einstieg, keine vollständige Rezeptdatenbank. Die [breitere Forever-Food-Liste](https://www.wowhead.com/forever/news/all-cooking-food-that-currently-gives-xp-buffs-in-wow-forever-382928) dient als Kataloggrundlage; jeder übernommene Eintrag benötigt einen passenden XP-Effekt. Ein gewöhnlicher Essens- oder Attributbuff allein genügt nicht als Nachweis.

Für den XP-Anteil gilt: geeignete Speisen sind Alternativen innerhalb derselben Kategorie. Das Addon soll keine Sammlung verschiedener Gerichte als zusätzliche stapelbare XP-Prozente darstellen. Bereits vorhandenes und nutzbares Essen hat Vorrang; die Klasse beeinflusst erst die Empfehlung für Zusatzattribute.

### Legacy-Vorteile

Blizzard beschreibt folgende relevante Vorteile: Well Rested erhöht Erholungslimit und Aufbaugeschwindigkeit, Gourmand verlängert Essensbuffs und Field Guide verkürzt die Aufstellabklingzeit für Campingobjekte. Diese erscheinen als dauerhafte Voraussetzungen beziehungsweise Verbesserungen und lösen keine gewöhnliche „Buff abgelaufen“-Warnung aus. Prozentwerte und Ränge werden erst nach Prüfung im Live-Client festgelegt. [Blizzard: Legacy-System](https://worldofwarcraft.blizzard.com/en-gb/news/24307383/get-to-know-the-world-of-warcraft-forever-legacy-system).

Der Legacy-Zugang entsteht mit dem ersten Legacy-Punkt, häufig durch Stufe 25 des ersten Charakters, aber auch über andere Herausforderungen. Daher ist „unter Stufe 25 nicht verfügbar“ als starre Regel falsch, insbesondere bei weiteren Charakteren. [Blizzard: Legacy-Zugang](https://worldofwarcraft.blizzard.com/en-gb/news/24307383/get-to-know-the-world-of-warcraft-forever-legacy-system).

### Ausnahmen und noch nicht bestätigte Quellen

- Student Fodder, ID 216619: Der aus SoD bekannte Erholungsbonus wurde für Forever entfernt. Daher kein fehlender XP-Buff. [Forever-spezifischer Änderungsbericht](https://www.wowhead.com/ptr/news/student-fodder-doesnt-give-rested-experience-in-wow-forever-383243).
- Archmagister's Perception ist als weiterer +10-%-Untoten-Effekt in der Datenbank enthalten. Die zugängliche Quelle und Beziehung zu Archmagister's Wisdom sind noch ungeklärt; kein zweiter pauschal fehlender Bonus. [Effekt](https://www.wowhead.com/forever/spell=1293736/archmagisters-perception).
- Discoverer's Delight, Winds of Wisdom, Variety-Show-Effekte und Adventure Awaits stehen in einem Beta-Datenkatalog. Datenbestand, Region und aktive Verfügbarkeit sind verschiedene Dinge. Keine automatische EU-Live-Empfehlung ohne passenden Nachweis. [Katalog mit Herkunftshinweisen](https://wowforever.one/tools/xp-calculator/).
- Für Retail-Quellen wie Kriegsmeutenbonus, Kriegsmodus oder Dunkelmond-XP wird keine Forever-Gültigkeit unterstellt. Saisonboni werden aufgenommen, sobald sie für Forever und EU belegt sind.
- Mehr Questangebote, Dungeonquests, Reisevorteile und stärkere Kampfbuffs können die Levelgeschwindigkeit erhöhen. Sie gehören nicht als angeblich fehlende direkte XP-Prozente in die Kernanzeige.

Es wird kein universeller „Gesamtbonus“ aus Kill-, Quest-, Untoten- und Erholungsboni errechnet, solange die aktuelle Stapelberechnung nicht geprüft ist. Angezeigte XP/Stunde beruhen auf tatsächlich erhaltenen XP; diese werden nicht nochmals mit Buff-Prozenten multipliziert.

## 3. Verhalten je Stufe und Verfügbarkeit

Die Übersicht wird bei jedem Stufenaufstieg und jeder relevanten Zustandsänderung aktualisiert. Ein Filter erlaubt zusätzlich die Vorschau auf jede Stufe von 1 bis 60.

| Bereich | Was standardmäßig angeboten wird |
| --- | --- |
| Stufe 1–13 | Nutzbares XP-Essen, Erholung und Camping entsprechend Freischaltung; Legacy bei bereits vorhandenem Zugang |
| Ab Stufe 14 | Zusätzlich Hinweis auf die eigene Schlafsack-Questreihe, ihren Fortschritt und später den Buff |
| Ab Stufe 30 | Zusätzlich Anhänger als situative Quelle beziehungsweise optionale Beschaffung |
| Jede Stufe | Passende Speisen, Berufsvoraussetzungen, accountabhängige Legacy-Vorteile und bestätigte aktive Events neu bewerten |
| Stufe 60 | Verlauf bleibt erhalten; Warnungen für normales Leveln und nächste-Level-Prognose werden ausgeblendet |

Zustände pro Quelle:

- Aktiv: Restzeit, Stapel oder Erholungsvorrat.
- Unvollständig: beispielsweise Schlafsack 1/3 statt 3/3.
- Läuft bald aus: konfigurierbare Vorwarnung.
- Fehlt, jetzt nutzbar: eine konkrete Aktion ist möglich.
- Beschaffung/Freischaltung offen: Stufe und Voraussetzungen passen, Gegenstand oder Questabschluss fehlen.
- Auf Abklingzeit beziehungsweise persönliche Sperre: zeigt nächsten möglichen Zeitpunkt.
- Situativ: beispielsweise Untotenbonus außerhalb eines passenden Einsatzes.
- Nicht verfügbar: Stufe, Beruf, Region oder Event passen nicht.
- Unbekannt: der Client liefert keine ausreichend prüfbare Information.
- Ignoriert: vom Nutzer abgeschaltet.

Alle erreichbaren Quellen stehen standardmäßig in der Übersicht. Wiederholte Erinnerungen gelten vor allem unmittelbar nutzbaren Quellen; offene Beschaffungen erzeugen einen Hinweis beim relevanten Meilenstein statt Daueralarm. Fehlendes eigenes Lederhandwerk verhindert nicht den Hinweis, dass ein fremdes Zelt nutzbar sein kann. Ohne belegte Umgebungsinformation verspricht das Addon kein Zelt in der Nähe.

## 4. Oberfläche und Erinnerungen

Ein verschiebbares, skalierbares Kompaktfenster verbindet Buffstatus und Tracker. Ein Klick öffnet die ausführliche Quellenliste und den Levelverlauf. Vorgeschlagener Befehl: `/fxp`.

Beispiel mit frei erfundenen Werten:

```text
Forever XP                  Stufe 24 · 62 %
XP-Essen       FEHLT         8 nutzbare Portionen
Schlafsack     3/3 aktiv     48:12 verbleibend
Erholung       1.240 XP      Zeltbezug in 12:40

XP/h aktiv     28.400        letzte 15 aktive Minuten
Level-up       in ca. 18 min aktiver Spielzeit
Sitzung        1:22          davon AFK 0:09
Gesamt /played 14:18         aktuelle Stufe 1:04
```

Jede Zeile enthält Symbol und Text; Farbe ist nur eine zusätzliche Orientierung. Tooltips nennen Wirkung, Geltungsbereich, Quelle, Voraussetzungen, passende Gegenstände und deren Vorrat. Bankbestand gilt nicht als sofort nutzbarer Taschenbestand.

Vorgeschlagene Standardwarnungen:

- Vorwarnung 60 Sekunden vor Ablauf und einmal beim Verlust eines relevanten Buffs.
- Erneute Erinnerung frühestens nach fünf Minuten; pro Quelle abschaltbar oder vorübergehend stumm.
- Schlafsack: auch fehlende Stapel erkennen; nicht schon allein wegen abgelaufener Gegenstandsabklingzeit zum Erneuern auffordern.
- Essen: während der nötigen Essenszeit nicht erneut zum Essen auffordern; abgebrochenes Essen anschließend neu bewerten.
- Erholung: Hinweis bei Verbrauch, erneuter Anspruch nur bei ausreichend belegtem Zustand.
- Im Kampf keine aufdringlichen Hinweise auf gerade nicht ausführbare Aktionen; nach dem Kampf erneut prüfen.
- Während AFK und Tod Warnungen zurückhalten, bei Rückkehr beziehungsweise Wiederbelebung den aktuellen Zustand prüfen.
- Textanzeige standardmäßig, Hinweiston optional. Keine automatische Gegenstandsnutzung.

## 5. XP-Tracker und Zeitdefinitionen

| Kennzahl | Definition |
| --- | --- |
| Gesamtspielzeit | Vom Spiel gemeldete gesamte Charakterspielzeit einschließlich AFK |
| Zeit auf aktueller Stufe | Vom Spiel gemeldete Stufenspielzeit, ergänzt durch laufende Aktualisierung |
| Sitzungszeit | Eingeloggte Zeit seit Sitzungsbeginn; ein UI-Neuladen darf die laufende Sitzung nicht unbeabsichtigt verlieren |
| AFK-Zeit | Separat für Sitzung und seit Messbeginn; soweit erkennbar auch pro aufgezeichneter Stufe |
| Aktive Zeit | Gemessene Onlinezeit minus erkannte AFK-Zeit und bewusst pausierte Messzeit |
| Aktuelle XP/Stunde | Tatsächlich erhaltene XP während der letzten 15 aktiven Minuten, auf eine Stunde hochgerechnet |
| Sitzungsrate | Sitzungs-XP geteilt durch aktive Sitzungszeit |
| Level-up-Prognose | Fehlende XP geteilt durch aktuelle aktive XP/Stunde |

Die Rate nutzt zeitlich begrenzte Messintervalle und zählt auch aktive Intervalle ohne XP. Eine lange Questabgabe-Serie oder Laufstrecke darf die Prognose beeinflussen. Die letzten 15 Minuten beziehen sich auf aktive Zeit; AFK hält das Fenster an. Nach einer langen Unterbrechung wird die alte Rate als veraltet markiert und die neue Prognose erst mit genügend frischen Daten gezeigt. Eine globale manuelle Pause hält XP-Zähler und zugehörige Messzeit gemeinsam an.

Standardprognose: „noch ca. 18 Minuten aktive Spielzeit“. Eine optionale Uhrzeit gilt nur unter der Annahme, dass ohne weitere AFK-Pausen weitergespielt wird. Unter zwei aktiven Minuten Messbasis erscheint „Daten werden gesammelt“; bei einer Rate von null erscheint keine scheinpräzise Restdauer.

AFK wird zunächst anhand des vom Spiel gemeldeten Status bestimmt, mit manueller Pause als Ergänzung. Stilles Warten, Chatten oder Berufeausüben kann nicht zuverlässig als persönliche Abwesenheit klassifiziert werden. Keine alleinige Bewegungserkennung: Sie würde unter anderem Angeln und Crafting falsch behandeln.

### Verlauf und Grenzen historischer Daten

- Pro abgeschlossenem Level: benötigte Onlinezeit, aufgezeichnete AFK-Zeit, aktive Zeit und gemessene XP/Stunde speichern.
- Daten mit Charakteridentität und Region/Regelsatz trennen; stabile Charakter-ID verwenden, sofern verfügbar.
- Bereits vor der Installation abgeschlossene Stufen sind nicht nachträglich einzeln rekonstruierbar.
- Gesamt- und aktuelle Stufenspielzeit können vom Spiel übernommen werden, sofern die Live-Schnittstelle sie liefert. Die AFK-Aufteilung ist erst ab Addon-Aufzeichnung bekannt.
- Bei Installation mitten im Level die vollständige verfügbare Stufenspielzeit anzeigen, aber die eigene AFK-/Aktivmessung als Teilaufzeichnung kennzeichnen. Historisch unbekannte AFK-Zeit niemals als null behandeln.
- Offlinezeit zählt weder als Spielzeit noch als AFK. Offline gewonnene Erholung wird beim Einloggen neu eingelesen.

## 6. Technischer Entwurf

Vorgeschlagen ist ein eigenständiges Lua-Addon mit nativen WoW-Oberflächenelementen und SavedVariables, ohne notwendige Abhängigkeit von WeakAuras, Ace3 oder externen Diensten. Der Nutzen liegt in kleiner Installation, wenig Wartung und klar prüfbarer Erfassung.

Es braucht nur wenige getrennte Teile: einen versionierten Quellenkatalog, Zustandserfassung und Regeln, Zeit-/XP-Messung sowie Oberfläche/Einstellungen. Der Katalog speichert Item- und Spell-IDs, tatsächliche Voraussetzungen, Geltungsbereich, Quellenlink und Verifizierungsstatus. Sprachabhängige Namen sind keine primären Erkennungsschlüssel.

Die Erfassung reagiert auf Ereignisse für XP, Stufe, Auren, Inventar, Abklingzeiten, AFK und Weltwechsel. Ein sparsamer Timer aktualisiert die sichtbaren Zeiten. Konkrete Ereignisnamen, Interface-Version und Zugriffsmöglichkeiten werden aus dem installierten Forever-Client geprüft, bevor die Implementierung festgelegt wird.

Besonders zu prüfen: Der allgemeine XP-Zusatzeffekt von Essen wird in der Datenbank als versteckt markiert. Deshalb darf die Erkennung nicht allein die Sichtbarkeit dieser einen Aura voraussetzen. Sie benötigt verifizierte Zuordnungen zu den tatsächlich sichtbaren Essensbuffs und ihren Laufzeiten. Unbekannte Attributbuffs werden nicht pauschal als XP-Essen akzeptiert. [Effektdaten](https://www.wowhead.com/forever/spell=1243969/well-fed-xp-boost).

Erste technische Arbeit nach Freigabe des Konzepts ist ein kleiner Live-Kompatibilitätscheck: lassen sich eigene XP, Gesamt-/Stufenspielzeit, AFK, Essens-/Schlafsackaura und Abklingzeiten in offener Welt sowie Dungeon lesen? Bei eingeschränkten Daten wird „unbekannt“ angezeigt. Der Entwurf verspricht vor diesem Check keine uneingeschränkte Aura-Erkennung in jeder Spielsituation.

## 7. Umfang der ersten Version

1. Live-Kompatibilität und die offenen Quellenwerte prüfen.
2. Verifiziertes XP-Essen, Schlafsack, Erholung, Zelt und situativen Anhänger integrieren; Legacy als Informations-/Voraussetzungsstatus, soweit lesbar.
3. Kompaktfenster, vollständige erreichbare Quellenliste, Vorwarnungen und einzelne Abschaltung.
4. Gesamt-/Stufenzeit, Sitzung, AFK, aktive Rate, Prognose und persistenter Levelverlauf.
5. Nutzbare Addon-ZIP mit kurzer deutscher Installationsanleitung.

Ein vollständiger Quest-Routenplaner, Auktionshaus-Preisvergleich, Cloud-Synchronisierung und allgemeiner Kampfbuff-Optimierer gehören zunächst nicht dazu.

## 8. Prüfung und Abnahme bei der Umsetzung

Relevante Regeln werden deterministisch geprüft: Levelgrenzen, vorhandenes/nicht nutzbares Essen, Buffverlust und Stapel, Zeltobergrenze und getrennte Sperren sowie Warnungsunterdrückung. Für den Tracker sind Levelwechsel mit XP-Übertrag, AFK-Ein-/Austritt, Nullrate, Questabgabe-Spitzen, Reload, Logout und Teilaufzeichnungen abzudecken.

Im Spiel prüfen: Login mit und ohne passende Items, Essen vollständig/abgebrochen, Schlafsack 1/3 und 3/3, Buffablauf und Erneuerung, Zelt bei wenig/viel Erholung, Dungeonwechsel und Stufenaufstieg. Die erste Auslieferung benennt offen, welche Situationen tatsächlich im Live-Client geprüft wurden.

## 9. Noch zu verifizieren

- Tatsächliche Live-Build-/Interface-Version und lesbare Daten in Dungeons beziehungsweise Kampf.
- Schlafsack-Verfügbarkeit, genaue Dauer und betroffene XP-Arten im aktuellen EU-Live-Build.
- Essens-Aura-Zuordnungen, weitere Speisen und etwaige Änderungen seit den Datenbank-Tooltips.
- Persönliche Zelt-Sperre und Einfluss von Legacy auf Aufstellabklingzeit und Buffdauer.
- Aktive EU-Live-Events sowie Erwerb und Effektzuordnung der Archmagister-Varianten.

Die grundlegenden Nutzerentscheidungen sind geklärt. Für noch offene Oberflächendetails gelten die oben beschriebenen Vorschläge als Entwurf.
