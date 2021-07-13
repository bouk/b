let
  ipAlias = ip:
  {
    "${interface}.${ip}" = {
      serviceConfig = {
        RunAtLoad = true;
        Label = "ke.bou.${interface}.${ip}";
        UserName = "root";
        ProgramArguments = [
          "/sbin/ifconfig"
          interface
          "alias"
          ip
        ];
      };
    };
  };
in

{
  launchd.daemons = (ipAlias "127.100.0.1") // (ipAlias "127.100.0.2");
};
