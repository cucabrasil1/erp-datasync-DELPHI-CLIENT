object modulo: Tmodulo
  OnCreate = DataModuleCreate
  Height = 651
  Width = 1235
  PixelsPerInch = 120
  object conexao: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'Database=C:\Siscom\server\bd\BASE.FDB'
      'DriverID=FB')
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    LoginPrompt = False
    Left = 30
    Top = 30
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 140
    Top = 30
  end
  object qrIntegrador: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'select * from c000440'
      'where codigo = '#39'-1'#39)
    Left = 390
    Top = 30
  end
  object qrParametrosIntegrador: TFDQuery
    Connection = conexao
    SQL.Strings = (
      'select * from c000441'
      'where codigo = '#39'-1'#39)
    Left = 390
    Top = 100
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrNone
    Left = 150
    Top = 120
  end
end
