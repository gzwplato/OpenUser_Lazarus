unit dm_users;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil;

type

    { TDataModule_Users }

    TDataModule_Users = class(TDataModule)
        SQLConnector_Users: TSQLConnector;
        SQLConnector_Users_Menus_Permisos: TSQLConnector;
        SQLConnector_Users_Passwords: TSQLConnector;
        SQLConnector_Users_Menus: TSQLConnector;
        SQLTransaction_Users: TSQLTransaction;
        SQLTransaction_Users_Menus_Permisos: TSQLTransaction;
        SQLTransaction_Users_Passwords: TSQLTransaction;
        SQLTransaction_Users_Menus: TSQLTransaction;
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    DataModule_Users: TDataModule_Users;

implementation

{$R *.lfm}

end.

