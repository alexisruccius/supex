ExUnit.start()

# set Mox's Port mock
Mox.defmock(Supex.Sclang.ScPortMock, for: Supex.Sclang.ScPort)
Application.put_env(:supex, :sc_port_mock, Supex.Sclang.ScPortMock)
