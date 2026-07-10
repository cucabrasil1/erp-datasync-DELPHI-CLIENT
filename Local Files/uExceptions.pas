unit uExceptions;


interface
  uses System.SysUtils;

  type
    BuscaIntegradorException = class(Exception)
    end;

    IntegradorNaoEncontradoException = class(Exception)
    end;

implementation

end.
