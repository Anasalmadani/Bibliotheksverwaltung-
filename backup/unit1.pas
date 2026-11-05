unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Grids, IBConnection, SQLDB, uBuch, uMitglied, uAusleihe, uBibliothekService;

type

  { TFormMain
    Hauptformular der Bibliotheksverwaltung.
    Aufgabe: Eingaben lesen, den Service aufrufen, Meldungen und Tabellen
    anzeigen. Fachregeln und Datenbankzugriff liegen in TBibliothekService. }
  TFormMain = class(TForm)
    { --- Reiter Bücher --- }
    ButtonBuchHinzufuegen: TButton;
    ButtonBuchSpeichern: TButton;
    ButtonBuchLoeschen: TButton;
    EditISBN: TEdit;
    EditTitel: TEdit;
    EditAutor: TEdit;
    EditJahr: TEdit;
    GroupBox1: TGroupBox;
    GridBuecher: TStringGrid;

    { --- Reiter Mitglieder --- }
    ButtonMitgliedHinzufuegen: TButton;
    ButtonMitgliedSpeichern: TButton;
    CheckBoxAktiv: TCheckBox;
    EditMitgliedName: TEdit;
    EditMitgliedEmail: TEdit;
    GroupBoxMitglied: TGroupBox;
    GridMitglieder: TStringGrid;

    { --- Reiter Ausleihen --- }
    ButtonAusleihen: TButton;
    ButtonRueckgabe: TButton;
    CheckBoxNurOffen: TCheckBox;
    ComboMitglied: TComboBox;
    ComboBuch: TComboBox;
    GroupBoxAusleihe: TGroupBox;
    GridAusleihen: TStringGrid;

    { --- Allgemein --- }
    PageControl1: TPageControl;
    StatusBar1: TStatusBar;
    TabBuecher: TTabSheet;
    TabMitglieder: TTabSheet;
    TabAusleihen: TTabSheet;

    { --- Datenbankkomponenten (werden an den Service übergeben) --- }
    IBConnection1: TIBConnection;
    SQLTransaction1: TSQLTransaction;

  private
    { Felder stehen immer vor den Methoden }
    FService: TBibliothekService;  { Fachlogik und Datenbankzugriff }
    FBuchISBNs: TStringList;       { ISBN zu jedem Eintrag in ComboBuch }
    FAnzeigeLaeuft: Boolean;       { verhindert Auswahl-Ereignisse beim Neuaufbau }

    { --- Einrichten --- }
    procedure GridVorbereiten(
      AGrid: TStringGrid;
      const ATitel: array of string;
      const ABreiten: array of Integer
    );
    procedure GridsEinrichten;
    procedure EreignisseZuweisen;

    { --- Platzhalter in den Eingabefeldern --- }
    procedure EditEinrichten(AEdit: TEdit);
    procedure PlatzhalterAnzeigen(AEdit: TEdit);
    function EditWert(AEdit: TEdit): string;
    procedure EditWertSetzen(AEdit: TEdit; const AText: string);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);

    { --- Eingaben --- }
    function JahrLesen(out AJahr: Integer): Boolean;
    function AusgewaehlteZelle(AGrid: TStringGrid): string;
    procedure BuchFelderLeeren;
    procedure MitgliedFelderLeeren;

    { --- Anzeige aktualisieren --- }
    procedure BuecherAnzeigen;
    procedure MitgliederAnzeigen;
    procedure AusleihenAnzeigen;
    procedure ComboBoxenFuellen;
    procedure StatusAktualisieren;
    procedure AllesAnzeigen;

    { --- Ereignisse der Tabellen und Auswahlfelder --- }
    procedure GridBuecherSelection(Sender: TObject; aCol, aRow: Integer);
    procedure GridMitgliederSelection(Sender: TObject; aCol, aRow: Integer);
    procedure GridAusleihenPrepareCanvas(
      Sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
    procedure CheckBoxNurOffenChange(Sender: TObject);

    { --- Ereignisse der Buttons --- }
    procedure ButtonBuchHinzufuegenClick(Sender: TObject);
    procedure ButtonBuchSpeichernClick(Sender: TObject);
    procedure ButtonBuchLoeschenClick(Sender: TObject);
    procedure ButtonMitgliedHinzufuegenClick(Sender: TObject);
    procedure ButtonMitgliedSpeichernClick(Sender: TObject);
    procedure ButtonAusleihenClick(Sender: TObject);
    procedure ButtonRueckgabeClick(Sender: TObject);

  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ ===================== Aufbau und Abbau ===================== }

constructor TFormMain.Create(TheOwner: TComponent);
begin
  { Lädt das Formular und erzeugt alle Komponenten }
  inherited Create(TheOwner);

  FBuchISBNs := TStringList.Create;
  FAnzeigeLaeuft := False;

  GridsEinrichten;

  EditEinrichten(EditISBN);
  EditEinrichten(EditTitel);
  EditEinrichten(EditAutor);
  EditEinrichten(EditJahr);
  EditEinrichten(EditMitgliedName);
  EditEinrichten(EditMitgliedEmail);
  CheckBoxAktiv.Checked := True;

  EreignisseZuweisen;

  { Service erzeugen. Er öffnet die Verbindung und lädt alle Daten.
    Bei einem Fehler wird das Programm beendet. }
  try
    FService := TBibliothekService.Create(IBConnection1, SQLTransaction1);
  except
    on E: Exception do
    begin
      ShowMessage('Datenbankfehler: ' + E.Message);
      FService := nil;
      Application.Terminate;
      Exit;
    end;
  end;

  AllesAnzeigen;
end;

destructor TFormMain.Destroy;
begin
  { Der Service gibt seine Objekte selbst frei.
    Verbindung und Transaktion gehören dem Formular. }
  FreeAndNil(FService);
  FreeAndNil(FBuchISBNs);
  inherited Destroy;
end;

{ ===================== Einrichten ===================== }

procedure TFormMain.GridVorbereiten(
  AGrid: TStringGrid;
  const ATitel: array of string;
  const ABreiten: array of Integer
);
var
  i: Integer;
begin
  { Reihenfolge ist wichtig: erst Spalten und feste Zeilen,
    danach die Zeilenanzahl (Kopfzeile + mindestens 1 Datenzeile) }
  AGrid.FixedCols := 0;
  AGrid.ColCount := Length(ATitel);
  AGrid.FixedRows := 1;
  AGrid.RowCount := 2;

  { Ganze Zeile auswählen, kein Tippen in Zellen }
  AGrid.Options := AGrid.Options + [goRowSelect] - [goEditing];

  for i := 0 to High(ATitel) do
  begin
    AGrid.Cells[i, 0] := ATitel[i];
    AGrid.ColWidths[i] := ABreiten[i];
  end;
end;

procedure TFormMain.GridsEinrichten;
begin
  GridVorbereiten(GridBuecher,
    ['ISBN', 'Titel', 'Autor', 'Jahr', 'Status'],
    [150, 260, 200, 70, 110]);

  GridVorbereiten(GridMitglieder,
    ['ID', 'Name', 'E-Mail', 'Aktiv'],
    [60, 220, 260, 80]);

  GridVorbereiten(GridAusleihen,
    ['ID', 'Buch', 'Mitglied', 'Ausgeliehen', 'Fällig', 'Überfällig'],
    [60, 240, 180, 110, 110, 150]);
end;

procedure TFormMain.EreignisseZuweisen;
begin
  ButtonBuchHinzufuegen.OnClick := @ButtonBuchHinzufuegenClick;
  ButtonBuchSpeichern.OnClick := @ButtonBuchSpeichernClick;
  ButtonBuchLoeschen.OnClick := @ButtonBuchLoeschenClick;

  ButtonMitgliedHinzufuegen.OnClick := @ButtonMitgliedHinzufuegenClick;
  ButtonMitgliedSpeichern.OnClick := @ButtonMitgliedSpeichernClick;

  ButtonAusleihen.OnClick := @ButtonAusleihenClick;
  ButtonRueckgabe.OnClick := @ButtonRueckgabeClick;

  GridBuecher.OnSelection := @GridBuecherSelection;
  GridMitglieder.OnSelection := @GridMitgliederSelection;
  GridAusleihen.OnPrepareCanvas := @GridAusleihenPrepareCanvas;
  CheckBoxNurOffen.OnChange := @CheckBoxNurOffenChange;
end;

{ ===================== Platzhalter in den Eingabefeldern ===================== }

procedure TFormMain.EditEinrichten(AEdit: TEdit);
begin
  AEdit.OnEnter := @EditEnter;
  AEdit.OnExit := @EditExit;
  PlatzhalterAnzeigen(AEdit);
end;

procedure TFormMain.PlatzhalterAnzeigen(AEdit: TEdit);
begin
  { Der Hinweis aus TextHint steht grau im Feld }
  AEdit.Text := AEdit.TextHint;
  AEdit.Font.Color := clGrayText;
end;

function TFormMain.EditWert(AEdit: TEdit): string;
begin
  { Liefert den echten Inhalt. Ein Platzhalter zählt als leer. }
  if AEdit.Font.Color = clGrayText then
    Result := ''
  else
    Result := Trim(AEdit.Text);
end;

procedure TFormMain.EditWertSetzen(AEdit: TEdit; const AText: string);
begin
  if AText = '' then
    PlatzhalterAnzeigen(AEdit)
  else
  begin
    AEdit.Text := AText;
    AEdit.Font.Color := clWindowText;
  end;
end;

procedure TFormMain.EditEnter(Sender: TObject);
var
  E: TEdit;
begin
  { Beim Anklicken: Platzhalter entfernen }
  E := Sender as TEdit;
  if E.Font.Color = clGrayText then
  begin
    E.Text := '';
    E.Font.Color := clWindowText;
  end;
end;

procedure TFormMain.EditExit(Sender: TObject);
var
  E: TEdit;
begin
  { Beim Verlassen: Ist das Feld leer, kommt der Platzhalter zurück }
  E := Sender as TEdit;
  if Trim(E.Text) = '' then
    PlatzhalterAnzeigen(E);
end;

{ ===================== Eingaben ===================== }
function TFormMain.JahrLesen(out AJahr: Integer): Boolean;
var
  JahrText: string;
begin
  { Ein leeres Jahr ist erlaubt und wird als 0 behandelt }
  Result := False;
  AJahr := 0;
  JahrText := EditWert(EditJahr);

  if JahrText = '' then
  begin
    Result := True;
    Exit;
  end;

  if not TryStrToInt(JahrText, AJahr) then
  begin
    ShowMessage('Bitte ein gültiges Jahr als Zahl eingeben.');
    Exit;
  end;

  Result := True;
end;

function TFormMain.AusgewaehlteZelle(AGrid: TStringGrid): string;
begin
  { Liefert den Wert der ersten Spalte der markierten Zeile,
    bei einer leeren Auswahl einen leeren Text }
  if AGrid.Row >= 1 then
    Result := Trim(AGrid.Cells[0, AGrid.Row])
  else
    Result := '';
end;

procedure TFormMain.BuchFelderLeeren;
begin
  PlatzhalterAnzeigen(EditISBN);
  PlatzhalterAnzeigen(EditTitel);
  PlatzhalterAnzeigen(EditAutor);
  PlatzhalterAnzeigen(EditJahr);
end;

procedure TFormMain.MitgliedFelderLeeren;
begin
  PlatzhalterAnzeigen(EditMitgliedName);
  PlatzhalterAnzeigen(EditMitgliedEmail);
  CheckBoxAktiv.Checked := True;
end;

{ ===================== Anzeige aktualisieren ===================== }

procedure TFormMain.BuecherAnzeigen;
var
  i, c, Zeilen: Integer;
  B: TBuch;
begin
  { Kopfzeile + Bücher, aber mindestens 2 Zeilen }
  Zeilen := FService.BuchAnzahl + 1;
  if Zeilen < 2 then
    Zeilen := 2;

  FAnzeigeLaeuft := True;
  GridBuecher.BeginUpdate;
  try
    GridBuecher.RowCount := Zeilen;

    for i := 1 to GridBuecher.RowCount - 1 do
      for c := 0 to GridBuecher.ColCount - 1 do
        GridBuecher.Cells[c, i] := '';

    for i := 0 to FService.BuchAnzahl - 1 do
    begin
      B := FService.BuchAnIndex(i);

      GridBuecher.Cells[0, i + 1] := B.ISBN;
      GridBuecher.Cells[1, i + 1] := B.Titel;
      GridBuecher.Cells[2, i + 1] := B.Autor;

      { Jahr 0 bedeutet "nicht angegeben" und bleibt leer }
      if B.Erscheinungsjahr > 0 then
        GridBuecher.Cells[3, i + 1] := IntToStr(B.Erscheinungsjahr);

      if B.Verliehen then
        GridBuecher.Cells[4, i + 1] := 'verliehen'
      else
        GridBuecher.Cells[4, i + 1] := 'verfügbar';
    end;
  finally
    GridBuecher.EndUpdate;
    FAnzeigeLaeuft := False;
  end;
end;

procedure TFormMain.MitgliederAnzeigen;
var
  i, c, Zeilen: Integer;
  M: TMitglied;
begin
  Zeilen := FService.MitgliedAnzahl + 1;
  if Zeilen < 2 then
    Zeilen := 2;

  FAnzeigeLaeuft := True;
  GridMitglieder.BeginUpdate;
  try
    GridMitglieder.RowCount := Zeilen;

    for i := 1 to GridMitglieder.RowCount - 1 do
      for c := 0 to GridMitglieder.ColCount - 1 do
        GridMitglieder.Cells[c, i] := '';

    for i := 0 to FService.MitgliedAnzahl - 1 do
    begin
      M := FService.MitgliedAnIndex(i);

      GridMitglieder.Cells[0, i + 1] := IntToStr(M.ID);
      GridMitglieder.Cells[1, i + 1] := M.Name;
      GridMitglieder.Cells[2, i + 1] := M.Email;

      if M.Aktiv then
        GridMitglieder.Cells[3, i + 1] := 'ja'
      else
        GridMitglieder.Cells[3, i + 1] := 'nein';
    end;
  finally
    GridMitglieder.EndUpdate;
    FAnzeigeLaeuft := False;
  end;
end;

procedure TFormMain.AusleihenAnzeigen;
var
  i, c, Zeile, Zeilen, Anzahl, Tage: Integer;
  A: TAusleihe;
  B: TBuch;
  M: TMitglied;
  Titel, MitgliedName, Status: string;
begin
  { Zuerst zählen, wie viele Zeilen angezeigt werden }
  Anzahl := 0;
  for i := 0 to FService.AusleiheAnzahl - 1 do
    if (not CheckBoxNurOffen.Checked) or FService.AusleiheAnIndex(i).IstOffen then
      Inc(Anzahl);

  Zeilen := Anzahl + 1;
  if Zeilen < 2 then
    Zeilen := 2;

  FAnzeigeLaeuft := True;
  GridAusleihen.BeginUpdate;
  try
    GridAusleihen.RowCount := Zeilen;

    for i := 1 to GridAusleihen.RowCount - 1 do
      for c := 0 to GridAusleihen.ColCount - 1 do
        GridAusleihen.Cells[c, i] := '';

    Zeile := 0;
    for i := 0 to FService.AusleiheAnzahl - 1 do
    begin
      A := FService.AusleiheAnIndex(i);

      if CheckBoxNurOffen.Checked and (not A.IstOffen) then
        Continue;

      Inc(Zeile);

      { Titel und Name aus den Listen des Service nachschlagen }
      B := FService.BuchSuchen(A.ISBN);
      if B <> nil then
        Titel := B.Titel
      else
        Titel := A.ISBN;

      M := FService.MitgliedSuchen(A.MitgliedID);
      if M <> nil then
        MitgliedName := M.Name
      else
        MitgliedName := '?';

      { Offene Ausleihen zeigen die Tage über der Frist,
        zurückgegebene das Rückgabedatum }
      if A.IstOffen then
      begin
        Tage := A.TageUeberfaellig(Date);
        if Tage = 1 then
          Status := '1 Tag'
        else if Tage > 1 then
          Status := IntToStr(Tage) + ' Tage'
        else
          Status := '';
      end
      else
        Status := 'zurück am ' + FormatDateTime('dd.mm.yyyy', A.ZurueckAm);

      GridAusleihen.Cells[0, Zeile] := IntToStr(A.ID);
      GridAusleihen.Cells[1, Zeile] := Titel;
      GridAusleihen.Cells[2, Zeile] := MitgliedName;
      GridAusleihen.Cells[3, Zeile] := FormatDateTime('dd.mm.yyyy', A.AusgeliehenAm);
      GridAusleihen.Cells[4, Zeile] := FormatDateTime('dd.mm.yyyy', A.FaelligAm);
      GridAusleihen.Cells[5, Zeile] := Status;
    end;
  finally
    GridAusleihen.EndUpdate;
    FAnzeigeLaeuft := False;
  end;
end;

procedure TFormMain.ComboBoxenFuellen;
var
  i: Integer;
  B: TBuch;
  M: TMitglied;
begin
  ComboMitglied.Items.Clear;
  ComboBuch.Items.Clear;
  FBuchISBNs.Clear;

  { Nur aktive Mitglieder. Die ID wird im Eintrag gespeichert. }
  for i := 0 to FService.MitgliedAnzahl - 1 do
  begin
    M := FService.MitgliedAnIndex(i);
    if M.Aktiv then
      ComboMitglied.Items.AddObject(M.Name, TObject(PtrInt(M.ID)));
  end;

  { Nur verfügbare Bücher. Die ISBN steht in der parallelen Liste. }
  for i := 0 to FService.BuchAnzahl - 1 do
  begin
    B := FService.BuchAnIndex(i);
    if not B.Verliehen then
    begin
      ComboBuch.Items.Add(B.Titel + ' (' + B.Autor + ')');
      FBuchISBNs.Add(B.ISBN);
    end;
  end;

  ComboMitglied.ItemIndex := -1;
  ComboBuch.ItemIndex := -1;
end;

procedure TFormMain.StatusAktualisieren;
var
  i, Offen, Ueberfaellig: Integer;
  A: TAusleihe;
begin
  Offen := 0;
  Ueberfaellig := 0;

  for i := 0 to FService.AusleiheAnzahl - 1 do
  begin
    A := FService.AusleiheAnIndex(i);
    if A.IstOffen then
    begin
      Inc(Offen);
      if A.IstUeberfaellig(Date) then
        Inc(Ueberfaellig);
    end;
  end;

  StatusBar1.SimpleText := Format(
    '%d Bücher, %d Mitglieder, %d Ausleihen offen, %d überfällig',
    [FService.BuchAnzahl, FService.MitgliedAnzahl, Offen, Ueberfaellig]);
end;

procedure TFormMain.AllesAnzeigen;
begin
  BuecherAnzeigen;
  MitgliederAnzeigen;
  AusleihenAnzeigen;
  ComboBoxenFuellen;
  StatusAktualisieren;
end;

{ ===================== Tabellen und Auswahlfelder ===================== }

procedure TFormMain.GridBuecherSelection(Sender: TObject; aCol, aRow: Integer);
var
  B: TBuch;
  Jahr: string;
begin
  { Beim Anklicken einer Zeile werden die Daten in die Felder geladen }
  if FAnzeigeLaeuft or (aRow < 1) then
    Exit;

  B := FService.BuchSuchen(GridBuecher.Cells[0, aRow]);
  if B = nil then
    Exit;

  if B.Erscheinungsjahr > 0 then
    Jahr := IntToStr(B.Erscheinungsjahr)
  else
    Jahr := '';

  EditWertSetzen(EditISBN, B.ISBN);
  EditWertSetzen(EditTitel, B.Titel);
  EditWertSetzen(EditAutor, B.Autor);
  EditWertSetzen(EditJahr, Jahr);
end;

procedure TFormMain.GridMitgliederSelection(Sender: TObject; aCol, aRow: Integer);
var
  M: TMitglied;
begin
  if FAnzeigeLaeuft or (aRow < 1) then
    Exit;

  M := FService.MitgliedSuchen(StrToIntDef(GridMitglieder.Cells[0, aRow], 0));
  if M = nil then
    Exit;

  EditWertSetzen(EditMitgliedName, M.Name);
  EditWertSetzen(EditMitgliedEmail, M.Email);
  CheckBoxAktiv.Checked := M.Aktiv;
end;

procedure TFormMain.GridAusleihenPrepareCanvas(
  Sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
begin
  { Kopfzeile und markierte Zeile nicht einfärben }
  if (aRow < 1) or (gdSelected in aState) then
    Exit;

  { Überfällige Ausleihen hellrot }
  if Pos(' Tag', GridAusleihen.Cells[5, aRow]) > 0 then
    GridAusleihen.Canvas.Brush.Color := RGBToColor(255, 215, 215);
end;

procedure TFormMain.CheckBoxNurOffenChange(Sender: TObject);
begin
  AusleihenAnzeigen;
end;

{ ===================== Bücher: Buttons ===================== }

procedure TFormMain.ButtonBuchHinzufuegenClick(Sender: TObject);
var
  Jahr: Integer;
  Titel, Fehlermeldung: string;
begin
  if not JahrLesen(Jahr) then
    Exit;

  Titel := EditWert(EditTitel);

  if FService.BuchHinzufuegen(
    EditWert(EditISBN), Titel, EditWert(EditAutor), Jahr, Fehlermeldung
  ) then
  begin
    AllesAnzeigen;
    BuchFelderLeeren;
    ShowMessage('Das Buch "' + Titel + '" wurde hinzugefügt.');
  end
  else
    ShowMessage(Fehlermeldung);
end;

procedure TFormMain.ButtonBuchSpeichernClick(Sender: TObject);
var
  ISBN, Titel, Fehlermeldung: string;
  Jahr: Integer;
begin
  { Gespeichert wird das Buch, das in der Tabelle markiert ist }
  ISBN := AusgewaehlteZelle(GridBuecher);
  if ISBN = '' then
  begin
    ShowMessage('Bitte zuerst ein Buch in der Tabelle auswählen.');
    Exit;
  end;

  if not JahrLesen(Jahr) then
    Exit;

  Titel := EditWert(EditTitel);

  if FService.BuchAendern(ISBN, Titel, EditWert(EditAutor), Jahr, Fehlermeldung) then
  begin
    AllesAnzeigen;
    BuchFelderLeeren;
    ShowMessage('Das Buch "' + Titel + '" wurde gespeichert.');
  end
  else
    ShowMessage(Fehlermeldung);
end;

procedure TFormMain.ButtonBuchLoeschenClick(Sender: TObject);
var
  ISBN, Titel, Fehlermeldung: string;
  B: TBuch;
begin
  ISBN := AusgewaehlteZelle(GridBuecher);
  if ISBN = '' then
  begin
    ShowMessage('Bitte zuerst ein Buch in der Tabelle auswählen.');
    Exit;
  end;

  B := FService.BuchSuchen(ISBN);
  if B <> nil then
    Titel := B.Titel
  else
    Titel := ISBN;

  { Sicherheitsabfrage }
  if MessageDlg(
    'Soll das Buch "' + Titel + '" wirklich gelöscht werden?',
    mtConfirmation, [mbYes, mbNo], 0
  ) <> mrYes then
    Exit;

  if FService.BuchLoeschen(ISBN, Fehlermeldung) then
  begin
    AllesAnzeigen;
    BuchFelderLeeren;
    ShowMessage('Das Buch "' + Titel + '" wurde gelöscht.');
  end
  else
    ShowMessage(Fehlermeldung);
end;

{ ===================== Mitglieder: Buttons ===================== }

procedure TFormMain.ButtonMitgliedHinzufuegenClick(Sender: TObject);
var
  MitgliedName, Fehlermeldung: string;
begin
  MitgliedName := EditWert(EditMitgliedName);

  if FService.MitgliedHinzufuegen(
    MitgliedName, EditWert(EditMitgliedEmail), Fehlermeldung
  ) then
  begin
    AllesAnzeigen;
    MitgliedFelderLeeren;
    ShowMessage('Das Mitglied "' + MitgliedName + '" wurde hinzugefügt.');
  end
  else
    ShowMessage(Fehlermeldung);
end;

procedure TFormMain.ButtonMitgliedSpeichernClick(Sender: TObject);
var
  ID: Integer;
  MitgliedName, Fehlermeldung: string;
begin
  { Gespeichert wird das Mitglied, das in der Tabelle markiert ist }
  ID := StrToIntDef(AusgewaehlteZelle(GridMitglieder), 0);
  if ID = 0 then
  begin
    ShowMessage('Bitte zuerst ein Mitglied in der Tabelle auswählen.');
    Exit;
  end;

  MitgliedName := EditWert(EditMitgliedName);

  if FService.MitgliedAendern(
    ID, MitgliedName, EditWert(EditMitgliedEmail),
    CheckBoxAktiv.Checked, Fehlermeldung
  ) then
  begin
    AllesAnzeigen;
    MitgliedFelderLeeren;
    ShowMessage('Das Mitglied "' + MitgliedName + '" wurde gespeichert.');
  end
  else
    ShowMessage(Fehlermeldung);
end;

{ ===================== Ausleihe und Rückgabe: Buttons ===================== }

procedure TFormMain.ButtonAusleihenClick(Sender: TObject);
var
  ISBN, Titel, MitgliedName, Fehlermeldung: string;
  MitgliedID: Integer;
  A: TAusleihe;
begin
  if (ComboMitglied.ItemIndex < 0) or (ComboBuch.ItemIndex < 0) then
  begin
    ShowMessage('Bitte ein Mitglied und ein Buch auswählen.');
    Exit;
  end;

  MitgliedID := Integer(PtrInt(ComboMitglied.Items.Objects[ComboMitglied.ItemIndex]));
  ISBN := FBuchISBNs[ComboBuch.ItemIndex];
  MitgliedName := ComboMitglied.Text;
  Titel := ComboBuch.Text;

  if FService.BuchAusleihen(ISBN, MitgliedID, Fehlermeldung) then
  begin
    AllesAnzeigen;

    { Die neueste Ausleihe steht an erster Stelle }
    A := FService.AusleiheAnIndex(0);
    ShowMessage('Ausgeliehen: ' + Titel + #13#10 +
      'an ' + MitgliedName + #13#10 +
      'Rückgabe bis ' + FormatDateTime('dd.mm.yyyy', A.FaelligAm) + '.');
  end
  else
    ShowMessage(Fehlermeldung);
end;

procedure TFormMain.ButtonRueckgabeClick(Sender: TObject);
var
  ID: Integer;
  Fehlermeldung: string;
begin
  { Zurückgegeben wird die Ausleihe, die in der Tabelle markiert ist }
  ID := StrToIntDef(AusgewaehlteZelle(GridAusleihen), 0);
  if ID = 0 then
  begin
    ShowMessage('Bitte zuerst eine Ausleihe in der Tabelle auswählen.');
    Exit;
  end;

  if FService.BuchZurueckgeben(ID, Fehlermeldung) then
  begin
    AllesAnzeigen;
    ShowMessage('Die Rückgabe wurde gebucht.');
  end
  else
    ShowMessage(Fehlermeldung);
end;

end.
