unit dm_historico_registros;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil;

type

    { TDataModule_historico_registros }

    TDataModule_historico_registros = class(TDataModule)
        SQLConnector: TSQLConnector;
        SQLConnector1: TSQLConnector;
        SQLTransaction: TSQLTransaction;
        SQLTransaction1: TSQLTransaction;
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    DataModule_historico_registros: TDataModule_historico_registros;

implementation

{$R *.lfm}

end.

