unit Model.Database.Manager;

interface

uses
  Model.Interfaces, Model.Types, FireDAC.Phys.IBWrapper, FireDAC.Phys.FB;

type
  TModelDataBaseManager = class(TInterfacedObject, IModelDatabaseManager)
  private
    FDataBaseInfo: TDataBase;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
  public
    constructor Create(ADataBaseInfo: TDataBase);
    destructor Destroy; override;

    procedure Backup(const ADestinyFile: string; const ALevel: integer);
    procedure Restore(const ABackupFile: string);
  end;

implementation

uses
  System.IOUtils;

{ TModelDataBaseManager }

procedure TModelDataBaseManager.Backup(const ADestinyFile: string; const ALevel: integer);
var
  FDFBNBackup1: TFDFBNBackup;
begin
  FDFBNBackup1.DriverLink := FDPhysFBDriverLink;

  FDFBNBackup1.UserName := FDataBaseInfo.UserName;
  FDFBNBackup1.Password := FDataBaseInfo.Password;
  FDFBNBackup1.Host := FDataBaseInfo.Server.IP;
  FDFBNBackup1.Protocol := ipTCPIP;

  FDFBNBackup1.Database := TPath.Combine(FDataBaseInfo.Path, 'ALTERDB.IB');
  FDFBNBackup1.BackupFile := ADestinyFile;
  FDFBNBackup1.Level := 0; // full backup

  FDFBNBackup1.Backup;
end;

constructor TModelDataBaseManager.Create(ADataBaseInfo: TDataBase);
begin
  FDataBaseInfo := ADataBaseInfo;
  FDPhysFBDriverLink := TFDPhysFBDriverLink.Create(nil);
  { TODO : definir parametro para a dll do firebird / sql }
  FDPhysFBDriverLink.VendorLib := 'C:\Program Files (x86)\Firebird\Firebird_3_0\fbclient.dll';
end;

destructor TModelDataBaseManager.Destroy;
begin
  FDPhysFBDriverLink.Free;
  inherited;
end;

procedure TModelDataBaseManager.Restore(const ABackupFile: string);
var
  FDFBNRestore1: TFDFBNRestore;
begin
  FDFBNRestore1 := TFDFBNRestore.Create(nil);
  try
    FDFBNRestore1.DriverLink := FDPhysFBDriverLink;

    FDFBNRestore1.UserName := FDataBaseInfo.UserName;
    FDFBNRestore1.Password := FDataBaseInfo.Password;
    FDFBNRestore1.Host     := FDataBaseInfo.Server.IP;
    FDFBNRestore1.Protocol := ipTCPIP;

    FDFBNRestore1.Database := TPath.Combine(FDataBaseInfo.Path, 'ALTERDB.IB');
    FDFBNRestore1.BackupFiles.Text := ABackupFile;

    FDFBNRestore1.Restore;
  finally
    FDFBNRestore1.Free;
  end;
end;

end.