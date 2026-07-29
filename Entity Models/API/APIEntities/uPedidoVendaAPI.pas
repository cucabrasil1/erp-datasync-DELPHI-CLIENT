unit uPedidoVendaAPI;

interface

uses
  System.JSON, System.SysUtils;

type
  TPedidoVendaAPI = class
  public
    class function ResourceName: string;
  end;

implementation

{ TPedidoVendaAPI }

class function TPedidoVendaAPI.ResourceName: string;
begin
  Result := '/pedidosvenda';
end;

end.
