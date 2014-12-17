unit dm_menus;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil;

type

    { TDataModule_Menus }

    TDataModule_Menus = class(TDataModule)
        SQLConnector: TSQLConnector;
        SQLTransaction: TSQLTransaction;
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    DataModule_Menus: TDataModule_Menus;

implementation

{$R *.lfm}

end.

