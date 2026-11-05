# 📚 Bibliotheksverwaltung

Eine objektorientierte Desktopanwendung zur Verwaltung einer kleinen Bibliothek. Entwickelt mit **Lazarus (Free Pascal)** und einer **Firebird-Datenbank**.

Die Anwendung ermöglicht die Verwaltung von Büchern und Mitgliedern sowie die Organisation von Ausleihen und Rückgaben.

---

## ✨ Funktionen

### 📖 Bücherverwaltung
- Bücher hinzufügen, bearbeiten und löschen
- ISBN als eindeutiger Schlüssel
- Anzeige des Buchstatus: verfügbar oder verliehen
- Sicherheitsabfrage vor dem Löschen
- Erscheinungsjahr validieren

### 👥 Mitgliederverwaltung
- Mitglieder hinzufügen und bearbeiten
- Mitglieder aktivieren und deaktivieren
- E-Mail-Adressen eindeutig speichern
- Mitglieder mit offenen Ausleihen können nicht deaktiviert werden

### 🔄 Ausleihverwaltung
- Bücher an Mitglieder ausleihen
- Rückgabe von Büchern buchen
- Anzeige aller offenen Ausleihen
- Filter für offene Ausleihen
- Überfällige Ausleihen farblich hervorheben
- Automatische Berechnung der Rückgabefrist

### 📊 Weitere Funktionen
- Statusleiste mit Anzahl der Bücher, Mitglieder und Ausleihen
- Verständliche Erfolgsmeldungen und Fehlermeldungen
- Daten bleiben nach einem Neustart erhalten
- Datenbankregeln werden zusätzlich durch Trigger abgesichert

---

## 🛠️ Verwendete Technologien

| Technologie | Verwendung |
|---|---|
| Free Pascal | Programmiersprache |
| Lazarus IDE | Entwicklungsumgebung |
| Firebird 3.0+ | Relationale Datenbank |
| SQL / SQLDB | Datenbankzugriff |
| IBConnection | Verbindung zur Firebird-Datenbank |
| DBeaver | Datenbankverwaltung und SQL-Ausführung |

---

## 🏗️ Projektarchitektur

Das Projekt wurde objektorientiert entwickelt. Die Anwendung trennt Datenklassen, Geschäftslogik und Benutzeroberfläche.

| Datei | Klasse | Aufgabe |
|---|---|---|
| `uBuch.pas` | `TBuch` | Datenklasse für Bücher |
| `uMitglied.pas` | `TMitglied` | Datenklasse für Mitglieder |
| `uAusleihe.pas` | `TAusleihe` | Datenklasse für Ausleihen |
| `uBibliothekService.pas` | `TBibliothekService` | Geschäftslogik und Datenbankzugriff |
| `Unit1.pas` | `TFormMain` | Hauptformular und Benutzeroberfläche |

### Architekturprinzip

Die Anwendung ist in drei Bereiche aufgeteilt:

1. **Benutzeroberfläche:** Nimmt Benutzereingaben entgegen und zeigt Daten an.
2. **Service-Schicht:** Enthält die Geschäftsregeln und den gesamten Datenbankzugriff.
3. **Datenklassen:** Bilden Bücher, Mitglieder und Ausleihen als Objekte ab.

Die Benutzeroberfläche enthält kein SQL. Sie kommuniziert mit dem Service, der wiederum die Datenklassen verwendet.

---

## 🗄️ Datenbankstruktur

Die Anwendung verwendet drei Haupttabellen:

| Tabelle | Beschreibung |
|---|---|
| `BUCH` | Speichert ISBN, Titel, Autor und Erscheinungsjahr |
| `MITGLIED` | Speichert ID, Name, E-Mail und Aktiv-Status |
| `AUSLEIHE` | Speichert Ausleihen und Rückgaben |

### Datenbankbeziehungen

- Ein Buch kann mehrere Ausleihen im Laufe der Zeit haben.
- Ein Mitglied kann mehrere Ausleihen im Laufe der Zeit haben.
- Die Tabelle `AUSLEIHE` verbindet Bücher und Mitglieder über Fremdschlüssel.

### Views

- `V_BUCH_STATUS`: Zeigt Bücher mit ihrem aktuellen Status (VERFÜGBAR oder VERLIEHEN).
- `V_VERLIEHEN`: Zeigt aktuell ausgeliehene Bücher, Mitglieder und überfällige Tage.

### Trigger und Datenbankregeln

Folgende Trigger sichern die Geschäftsregeln:

- `AUSLEIHE_BI`: Prüft neue Ausleihen und setzt die Leihfrist.
- `AUSLEIHE_BU`: Schützt bestehende Ausleihen vor unerlaubten Änderungen.
- `AUSLEIHE_BD`: Verhindert das Löschen von Ausleihen.

Zusätzlich werden Datenbank-Exceptions für wichtige Fehlerfälle verwendet.

### Geschäftsregeln

- Ein Buch darf nur einmal gleichzeitig ausgeliehen werden.
- Ein Mitglied darf höchstens drei Bücher gleichzeitig ausleihen.
- Die Leihfrist beträgt 28 Tage.
- Inaktive Mitglieder dürfen keine Bücher ausleihen.
- Ausleihen werden nicht gelöscht, sondern durch eine Rückgabe abgeschlossen.
- Bücher mit vorhandenen Ausleihen können nicht gelöscht werden.
- Mitglieder mit offenen Ausleihen können nicht deaktiviert werden.
- ISBN und E-Mail-Adresse müssen eindeutig sein.

Die wichtigen Regeln werden sowohl im Programm als auch in der Datenbank geprüft.

---

## 📂 Repository-Struktur

```text
Bibliotheksverwaltung/
│
├── README.md
├── .gitignore
│
├── database/
│   └── bibliotheksverwaltung.sql
│
├── backup/
│
├── lib/
│   └── x86_64-linux/
│
├── Unit1.pas
├── Unit1.lfm
├── uBuch.pas
├── uMitglied.pas
├── uAusleihe.pas
├── uBibliothekService.pas
└── Bibliotheksverwaltung.lpi
```

*Hinweis: Die Struktur zeigt die vorgesehene Organisation. Die Dateien müssen entsprechend im Repository vorhanden sein.*

---

## ⚙️ Installation und Start

### Voraussetzungen

- Lazarus IDE mit Free Pascal
- Firebird Server ab Version 3.0
- Passende Firebird-Clientbibliothek
- Optional: DBeaver

### 1. Repository herunterladen

```bash
git clone https://github.com/Anasalmadani/Bibliotheksverwaltung.git
```

### 2. Datenbank erstellen

Das SQL-Skript befindet sich unter:

`database/bibliotheksverwaltung.sql`

Das Skript enthält:

- Erstellung der Tabellen
- Erstellung der Indizes
- Definition der Datenbank-Exceptions
- Erstellung der Trigger
- Erstellung der Views

Das Skript kann mit DBeaver auf einer Firebird-Datenbank ausgeführt werden.

### 3. Datenbankverbindung konfigurieren

In Lazarus müssen die Verbindungsparameter von `IBConnection1` konfiguriert werden:

- HostName
- DatabaseName
- UserName
- Password
- CharSet: UTF8
- LoginPrompt: False

Die konkreten Verbindungsdaten hängen von der verwendeten Firebird-Installation ab.

### 4. Projekt starten

1. Projektdatei in Lazarus öffnen.
2. Datenbankverbindung konfigurieren.
3. Projekt neu kompilieren.
4. Anwendung starten.

---

## 🔐 Sicherheit

- Keine echten Datenbankpasswörter in GitHub veröffentlichen.
- Keine vertraulichen Serverinformationen hochladen.
- Zugangsdaten sollten außerhalb des öffentlichen Repositorys gespeichert werden.

---

## 🧪 Testfälle

Folgende Funktionen sind für die Überprüfung vorgesehen:

| Nr. | Test | Erwartetes Ergebnis |
|---|---|---|
| 1 | Programm starten | Datenbankverbindung funktioniert |
| 2 | Buch hinzufügen | Buch wird gespeichert |
| 3 | Doppelte ISBN hinzufügen | Fehlermeldung |
| 4 | Buch ohne Titel hinzufügen | Fehlermeldung |
| 5 | Ungültiges Erscheinungsjahr | Eingabe wird abgelehnt |
| 6 | Buch bearbeiten | Änderung wird gespeichert |
| 7 | Doppelte E-Mail-Adresse | Fehlermeldung |
| 8 | Buch ausleihen | Ausleihe wird gespeichert |
| 9 | Bereits verliehenes Buch ausleihen | Ausleihe wird verhindert |
| 10 | Viertes Buch ausleihen | Ausleihe wird verhindert |
| 11 | Mitglied deaktivieren | Mitglied wird nicht mehr zur Ausleihe angeboten |
| 12 | Mitglied mit offener Ausleihe deaktivieren | Vorgang wird abgelehnt |
| 13 | Buch zurückgeben | Buch wird wieder verfügbar |
| 14 | Buch mit Ausleihen löschen | Löschen wird verhindert |
| 15 | Programm neu starten | Gespeicherte Daten bleiben erhalten |

---

## 🚀 Mögliche Erweiterungen

- Suchfunktion für Bücher und Mitglieder
- Verlängerung der Leihfrist
- Mahnliste für überfällige Bücher
- Statistiken zu den meist ausgeliehenen Büchern
- CSV-Export
- Benutzeranmeldung und unterschiedliche Benutzerrollen

---

## 🎯 Projektziel

Ziel dieses Projekts ist die Entwicklung einer objektorientierten Desktopanwendung mit Lazarus und Free Pascal.

Dabei werden praktische Kenntnisse in folgenden Bereichen angewendet:

- Objektorientierte Programmierung (OOP)
- Klassen, Objekte und Methoden
- Trennung von Geschäftslogik und Benutzeroberfläche
- Relationale Datenbanken
- SQL und Firebird
- Datenbankverbindungen und Transaktionen
- Fehlerbehandlung und Datenvalidierung

---

## 👨‍💻 Autor

**Anas Almadani**

GitHub: [@Anasalmadani](https://github.com/Anasalmadani)

**Projekt:** Bibliotheksverwaltung  
**Entwicklungsumgebung:** Lazarus / Free Pascal  
**Datenbank:** Firebird

