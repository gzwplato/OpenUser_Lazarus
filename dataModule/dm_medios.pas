unit dm_medios;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, LR_Class;

type

    { TDataModule_Medios }

    TDataModule_Medios = class(TDataModule)
        SQLConnector: TSQLConnector;
        SQLTransaction: TSQLTransaction;
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    DataModule_Medios: TDataModule_Medios;

implementation

{$R *.lfm}

end.

