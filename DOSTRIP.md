# TRIP für DOS v1.0 / (c) 1997 M. Beyer
---

Oft sind es gerade die absolut simplen Spielideen, die einen erstaunlich hohen Suchtfaktor entwickeln (das sogenannte "Tetris-Syndrom"). Das Spielprinzip von TRIP ist eine solche Idee und basiert auf einem Brettspiel aus den 70er-Jahren namens TRIPPPLES.

Das Spielfeld von TRIP besteht aus 8×8 Feldern, die nach dem Zufallsprinzip angeordnet werden (mit Ausnahme von sechs speziellen Feldern, die immer dieselbe Position haben). Zwei Spieler treten gegeneinander an und ziehen abwechselnd ihre Spielfigur auf ein jeweils angrenzendes Nachbarfeld - horizontal, vertikal oder diagonal.

Sie beginnen Seite an Seite auf zwei farbig markierten Startfeldern in der Mitte des unteren Spielfeldrandes.

Die anderen vier Felder mit fester Position sind durch gelbe Kreise markiert. Sie befinden sich in den Ecken des Spielfeldes, jeweils ein Feld von den Rändern entfernt.

Das Ziel des Spiels besteht darin, den eigenen Spielstein vom Startfeld zum nächstgelegenen gelben Kreis zu bewegen, von dort aus zum darüberliegenden Kreis, anschließend quer über das Spielfeld zum gegenüberliegenden Kreis, dann auf der anderen Seite hinunter zum Kreis, der dem gegnerischen Startfeld am nächsten liegt, und schließlich zum Startfeld des Gegners selbst.

Wer diesen Parcours zuerst vollständig absolviert, gewinnt das Spiel.

## Der besondere Clou

Der trickreiche (und spaßige) Teil des Spiels ist folgender:

Die meisten der übrigen Felder enthalten eine Reihe von Pfeilen, die jeweils in drei von acht möglichen Richtungen zeigen. Befindet sich die eigene Spielfigur auf einem solchen Feld, geben diese Pfeile die Richtungen vor, in die sich die Figur des **GEGNERS** bei dessen nächstem Zug bewegen darf.

Wenn Sie beispielsweise einen Zug auf ein Feld machen, dessen Pfeile nach links, unten und rechts oben zeigen, so sind dies die einzigen drei Richtungen, in die Ihr Gegner seine Figur anschließend ziehen darf.

Befinden Sie sich auf einem Feld ohne Pfeile (den beiden Startfeldern, den vier Kreisen oder einem der zwei zufällig platzierten "Blanko-Felder"), darf der Gegner in jede der acht möglichen Richtungen ziehen.

Allerdings kann er seine Figur weder über den Spielfeldrand hinaus bewegen noch auf das Feld ziehen, auf dem sich Ihre Figur gerade befindet. Daher ist die Zahl der tatsächlich möglichen Spielzüge oftmals geringer als die acht bzw. drei Richtungen, die das Feld des Gegners grundsätzlich vorgibt.

Tatsächlich kann es vorkommen, daß einem Spieler kein erlaubter Zug mehr bleibt. In diesem Fall gewinnt der andere Spieler die Partie.

Strategisch ungünstig ist es daher, sich mit seiner Figur am Spielfeldrand - insbesondere in den Ecken - aufzuhalten. Hier ist die Gefahr am größten, daß der Gegner einen Zug findet, der die eigene Figur in eine ausweglose Situation bringt.

## Zum Programm

Nach dem Programmstart baut TRIP zunächst das Spielfeld auf und prüft anschließend, ob ein Maustreiber installiert ist.

Unabhängig vom Ergebnis dieser Prüfung läßt sich TRIP vollständig mit der Tastatur bedienen. Ist ein entsprechender Treiber vorhanden, wird zusätzlich der Mauszeiger eingeblendet und das Spiel kann auch vollständig mit der Maus gesteuert werden.

Die Spielfiguren werden durch farbige Rechtecke dargestellt, welche das jeweils besetzte Feld umranden (grün bzw. rot). Das Rechteck des Spielers, der gerade am Zug ist, blinkt.

Um seine Figur zu ziehen, klickt man entweder das gewünschte Zielfeld mit der linken Maustaste an oder benutzt den numerischen Ziffernblock:

- **4 / 6** - links / rechts
- **8 / 2** - hoch / runter
- **7 / 9 / 1 / 3** - diagonal

Das jeweils nächste zu erreichende Zielfeld (Teilziel) eines Spielers wird durch einen Kreis in dessen Farbe dargestellt.

Rechts neben dem eigentlichen Spielfeld befinden sich die Statusanzeige sowie direkt darunter das Menü.

An der Statusanzeige läßt sich unter anderem ablesen, welcher Spieler (rotes oder grünes Rechteck) gerade am Zug ist. Viel interessanter ist jedoch die Anzeige der aktuell erlaubten Zugrichtungen. Daneben erscheinen gelegentlich verschiedene Statusmeldungen.

Je nachdem, welcher Spieler von einer solchen Meldung betroffen ist, erscheint sie in Rot oder Grün:

**GAME OVER!** - Das Spiel wurde durch das Erreichen aller fünf Teilziele eines Spielers beendet. Die Meldung erscheint in der Farbe des Verlierers.

**KEIN ZUG MÖGLICH!** - Das Spiel wurde beendet, weil ein Spieler keinen erlaubten Zug mehr ausführen kann. Die Meldung erscheint in der Farbe dieses Spielers.

**WIR HABEN EINEN GEWINNER** - Allgemeine Meldung bei Spielende, in der Farbe des Gewinners.

**MAL ÜBERLEGEN** - Ein Computer-Spieler ist gerade dabei, seinen nächsten Zug zu berechnen.

## Das Menü

Bei Mausbedienung funktionieren die eingerahmten Menüpunkte wie Buttons.

Für jeden Menüpunkt gibt es außerdem einen Hotkey, der hinter dem Namen in gelber Schrift angezeigt wird.

Hier nun die Bedeutung der einzelnen Menüpunkte:

**NEUES SPIEL [F10]** - Das Spielfeld wird neu gemischt und der Spieler, der den ersten Zug machen darf, wechselt. Alle anderen Einstellungen bleiben erhalten.

**ZUGVORSCHLAG [v]** - Dieser Menüpunkt kann jederzeit auch durch Drücken der rechten Maustaste aktiviert werden.

Der Computer schlägt - abhängig vom jeweils eingestellten LEVEL (siehe weiter unten) - einen mehr oder weniger durchdachten Zug vor.

Das vorgeschlagene Zielfeld wird durch ein weißes, flackerndes Rechteck hervorgehoben. Ein Druck auf eine beliebige Taste oder die linke Maustaste beendet diese Anzeige.

**ZUG ZURÜCK [z]** - Mit dieser Option kann ein beliebiger Spielzug (COMPUTER oder MENSCH) rückgängig gemacht werden. Es ist möglich, auf diese Weise bis zu 100 Spielzüge zurückzugehen.

**SPIELER GRÜN [F1] / SPIELER ROT [F2]** - Legt fest, ob die jeweilige Spielfigur von einem Menschen oder vom Computer gesteuert wird.

**LEVEL GRÜN [F3] / LEVEL ROT [F4]** - Legt die Spielstärke einer Figur fest. Wird die betreffende Figur von einem Menschen gesteuert, bestimmt diese Einstellung die Suchtiefe des Computers für den Menüpunkt "ZUGVORSCHLAG".

Dabei stehen drei unterschiedlich anspruchsvolle Strategien zur Verfügung:

- **LEVEL "schwach":** Der Computer betrachtet ausschließlich seine eigenen möglichen Züge und wählt denjenigen, der ihn seinem nächsten Teilziel am weitesten näherbringt. Die möglichen Reaktionen des Gegners bleiben dabei unberücksichtigt.

- **LEVEL "bescheiden" und höher:** Der Computer verwendet eine rekursive Suchstrategie (Minimax). Dabei untersucht er nicht nur seine eigenen möglichen Züge, sondern berücksichtigt auch die darauf folgenden Reaktionen des Gegners. Er versucht, für sich möglichst günstige Zugfolgen zu finden, während er gleichzeitig versucht, die Erfolge der Züge des Gegener zu minimieren. Er geht dabei davon aus, daß der Gegner stets den für ihn besten Zug wählen wird. Je höher das Level (Rekursionstiefe), desto weiter blickt der Computer voraus und desto mehr mögliche Zugfolgen werden bei seiner Entscheidung berücksichtigt.

"bescheiden" arbeitet dabei mit einer Rekursionstiefe von 2, "durchschnitt" mit einer Rekursionstiefe von 3, u.s.w., bis hin zu "gottgleich" mit einer Tiefe von 12. Auf einem älteren Rechner, beispielsweise einem 486DX2, entsteht dabei eine kurze Denkpause.

**SCHLEIFEN [s]** - Legt fest, ob es dem Computer erlaubt ist, komplette Zugsequenzen mehr als zweimal zu wiederholen. Zwei Computer-Spieler würden andernfalls gemäß dieser Strategie möglicherweise in einer Endlosschleife hängen bleiben.

Berücksichtigt werden die letzten 50 Züge.

**ENDE [Esc]** - Sofortige Rückkehr zu DOS.

## Sonstiges

TRIP verwendet standardmäßig die leicht verzerrte EGA-Auflösung von 640 × 350 Punkten.

Gibt man als Kommandozeilenparameter 'vga' an, wird stattdessen eine VGA-spezifische Auflösung mit einem besseren Seitenverhältnis (640 × 480), aber geringerer Lesbarkeit aufgrund der kleineren Darstellung gewählt.

Dabei wird eine VGA-Karte vorausgesetzt. Eine entsprechende Hardwareprüfung findet nicht statt.

---

TRIP wurde mit Turbo Pascal 7.0 entwickelt. Dies ist die DOS-Version; eine entsprechende Version für Windows ist geplant.

Zum jetzigen Zeitpunkt steht allerdings noch nicht genau fest, in welcher Sprache ich die Windows-Version entwickeln werde (entweder Turbo Pascal für Windows 1.5 oder eventuell C++ 3.1). Vor allem ist noch unklar, **WANN** ich dafür Zeit finden werde: zu wenig Erfahrung mit der Programmierung unter Windows und ganz allgemein zu viel um die Ohren.

TRIP ist SHAREWARE. Das Programm darf zu nichtkommerziellen Zwecken weitergegeben und genutzt werden.

Über Feedback jeder Art freue ich mich - insbesondere über Anregungen, Verbesserungsvorschläge und natürlich Bug-Reports.

An Tantiemen bin ich übrigens nicht interessiert; DOS-Software ist ja ohnehin tot. :-<

**P.S.:** Der Sourcecode ist eine einzige Katastrophe und kann daher niemandem ernsthaft zugemutet werden. Bis heute habe ich noch nicht ergründen können, warum er überhaupt den Compilerlauf übersteht. :*)

## Die Tastatursteuerung (Unit MFII)

Für die Tastaturabfrage verwendet TRIP die eigens entwickelte Turbo-Pascal-Unit **MFII**. Sie ermöglicht unter anderem die Erkennung einer erweiterten MF-II-Tastatur, das Abfragen einzelner Tasten und Tastenkombinationen sowie den direkten Zugriff auf den Tastaturpuffer.

Darüber hinaus enthält sie einige zusätzliche Hilfsfunktionen, beispielsweise zur Steuerung der Cursorform und zur Erzeugung von Tönen. Dabei werden teilweise direkt BIOS-Funktionen und Hardware-Ports angesprochen, um Unzulänglichkeiten bestimmter BIOS-Versionen zu umgehen.