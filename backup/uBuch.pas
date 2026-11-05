unit uBuch;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  { TBuch
    Datenklasse für ein Buch. Jedes Buch gibt es nur einmal.
    Kein Datenbankzugriff, das macht der Service. }
  TBuch = class
  private
    FISBN: string;
    FTitel: string;
    FAutor: string;
    FErscheinungsjahr: Integer;  { 0 = unbekannt }
    FVerliehen: Boolean;
  public
    constructor Create(
      const AISBN, ATitel, AAutor: string;
      AErscheinungsjahr: Integer
    );

    { Nur lesbar: Die ISBN ist der Schlüssel und bleibt fest }
    property ISBN: string read FISBN;

    property Titel: string read FTitel write FTitel;
    property Autor: string read FAutor write FAutor;
    property Erscheinungsjahr: Integer
      read FErscheinungsjahr write FErscheinungsjahr;

    { Wird nur vom Service gesetzt, abgeleitet aus den offenen Ausleihen }
    property Verliehen: Boolean read FVerliehen write FVerliehen;
  end;

implementation

constructor TBuch.Create(
  const AISBN, ATitel, AAutor: string;
  AErscheinungsjahr: Integer
);
begin
  inherited Create;

  FISBN := Trim(AISBN);
  FTitel := Trim(ATitel);
  FAutor := Trim(AAutor);
  FErscheinungsjahr := AErscheinungsjahr;
  FVerliehen := False;  { neues Buch ist verfügbar }
end;

end.
