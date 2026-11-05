# 📚 Bibliotheksverwaltung

Eine Desktopanwendung zur Verwaltung einer kleinen Bibliothek. Entwickelt mit **Lazarus (Free Pascal)** und einer **Firebird-Datenbank**.

Die Anwendung ermöglicht die Verwaltung von Büchern und Mitgliedern sowie die Buchung von Ausleihen und Rückgaben.

## ✨ Funktionen

### 📖 Bücherverwaltung
- Bücher hinzufügen, bearbeiten und löschen
- Anzeige des Buchstatus: verfügbar oder verliehen
- Sicherheitsabfrage vor dem Löschen
- ISBN als eindeutiger Schlüssel

### 👥 Mitgliederverwaltung
- Mitglieder hinzufügen und bearbeiten
- Mitglieder aktivieren und deaktivieren
- E-Mail-Adressen eindeutig speichern
- Mitglieder mit offenen Ausleihen können nicht deaktiviert werden

### 🔄 Ausleihverwaltung
- Bücher an Mitglieder ausleihen
- Rückgabe von Büchern buchen
- Anzeige offener Ausleihen
- Filter für offene Ausleihen
- Überfällige Ausleihen werden farblich hervorgehoben

### 📊 Weitere Funktionen
- Statusleiste mit Anzahl der Bücher, Mitglieder und Ausleihen
- Verständliche Erfolgsmeldungen und Fehlermeldungen
- Automatische Berechnung der Rückgabefrist
- Speicherung aller Daten in einer Firebird-Datenbank

## 🛠️ Verwendete Technologien

- **Programmiersprache:** Free Pascal
- **Entwicklungsumgebung:** Lazarus IDE
- **Datenbank:** Firebird 3.0 oder höher
- **Datenbankverwaltung:** DBeaver (optional)
- **Datenbankkomponenten:** SQLDB / IBConnection

## 🏗️ Projektarchitektur

Das Projekt ist objektorientiert aufgebaut und trennt Datenmodelle, Geschäftslogik und Benutzeroberfläche.

| Datei | Aufgabe |
|---|---|
| `uBuch.pas` | Datenklasse für Bücher |
| `uMitglied.pas` | Datenklasse für Mitglieder |
| `uAusleihe.pas` | Datenklasse für Ausleihen |
| `uBibliothekService.pas` | Geschäftslogik und Datenbankzugriff |
| `Unit1.pas` | Hauptformular und Benutzeroberfläche |

Die Benutzeroberfläche kommuniziert mit dem Service. Der Service verwaltet die Geschäftsregeln und den Datenbankzugriff.

## 🗄️ Datenbankstruktur

Die Anwendung verwendet drei Haupttabellen:

- `BUCH` – speichert die Buchinformationen.
- `MITGLIED` – speichert die Mitgliederdaten.
- `AUSLEIHE` – speichert Ausleihen und Rückgaben.

Zusätzlich werden zwei Datenbank-Views verwendet:

- `V_BUCH_STATUS` – zeigt an, ob ein Buch verfügbar oder verliehen ist.
- `V_VERLIEHEN` – zeigt aktuell verliehene Bücher und überfällige Ausleihen.

### Geschäftsregeln

- Ein Buch kann nur einmal gleichzeitig ausgeliehen werden.
- Ein Mitglied darf höchstens drei Bücher gleichzeitig ausleihen.
- Die reguläre Leihfrist beträgt 28 Tage.
- Inaktive Mitglieder dürfen keine Bücher ausleihen.
- Ausleihen werden nicht gelöscht, sondern durch eine Rückgabe abgeschlossen.
- Datenbank-Trigger sichern wichtige Regeln zusätzlich ab.

## ⚙️ Installation und Start

### Voraussetzungen

- Lazarus IDE mit Free Pascal
- Firebird Server ab Version 3.0
- Passende Firebird-Clientbibliothek
- Optional: DBeaver

### Einrichtung

1. Firebird-Datenbank erstellen.
2. Das SQL-Skript aus der Projektdokumentation in DBeaver ausführen.
3. Das Projekt in Lazarus öffnen.
4. Die Datenbankverbindung in `IBConnection1` konfigurieren.
5. Zugangsdaten und Serverinformationen eintragen.
6. Projekt neu kompilieren und starten.

**Wichtig:** Zugangsdaten und Passwörter dürfen nicht in ein öffentliches GitHub-Repository hochgeladen werden. Vor dem Veröffentlichen müssen vertrauliche Verbindungsdaten aus der Projektkonfiguration entfernt werden.

## 🧪 Tests

Folgende Funktionen sollen getestet werden:

- Bücher hinzufügen, bearbeiten und löschen
- Doppelte ISBN verhindern
- Mitglieder hinzufügen und deaktivieren
- Doppelte E-Mail-Adressen verhindern
- Ausleihlimit von drei Büchern prüfen
- Doppelte gleichzeitige Ausleihe verhindern
- Rückgabe eines Buches durchführen
- Überfällige Ausleihen erkennen
- Daten nach einem Neustart weiterhin anzeigen

## 🚀 Mögliche Erweiterungen

- Suchfunktion für Bücher und Mitglieder
- Verlängerung der Leihfrist
- Mahnliste für überfällige Bücher
- Statistiken zu den meist ausgeliehenen Büchern
- CSV-Export

## 👨‍💻 Projektziel

Ziel dieses Projekts ist die Entwicklung einer objektorientierten Desktopanwendung mit Lazarus und Free Pascal. Dabei werden praktische Kenntnisse in der Softwareentwicklung, Datenbankanbindung, SQL, OOP und der Trennung von Geschäftslogik und Benutzeroberfläche angewendet.
