object AcrylicDNSProxySvc: TAcrylicDNSProxySvc
  AllowPause = False
  DisplayName = 'Acrylic DNS Proxy'
  AfterInstall = ServiceAfterInstall
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 188
  Width = 269
  PixelsPerInch = 120
end
