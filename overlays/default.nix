self: super:
{
  mockgen = self.buildGoModule rec {
    pname = "mockgen";
    version = "1.4.4";
    src = self.fetchFromGitHub {
      owner = "golang";
      repo = "mock";
      rev = "v${version}";
      sha256 = "1lj0dvd6div4jaq1s0afpwqaq9ah8cxhkq93wii2ably1xmp2l0a";
    };
    vendorSha256 = "1md4cg1zzhc276sc7i2v0xvg5pf6gzy0n9ga2g1lx3d572igq1wy";
    doCheck = false;
    subPackages = [ "mockgen" ];
  };

  ifacemaker = self.buildGoModule rec {
    pname = "ifacemaker";
    version = "1.1.0";
    src = self.fetchFromGitHub {
      owner = "vburenin";
      repo = "ifacemaker";
      rev = "v${version}";
      sha256 = "1cifa3gpfks96vfzscc71v5f3g34c6kcifcgpvn9fn10dk9cqa4s";
    };
    vendorSha256 = "1mzkj4j9wzi5m3mlb78hyjgzdxbxcxh2si1f6pppbxi555bnsrih";
  };

  tparse = self.buildGoModule rec {
    pname = "tparse";
    version = "0.7.4";
    src = self.fetchFromGitHub {
      owner = "mfridman";
      repo = "tparse";
      rev = "v${version}";
      sha256 = "1aqi9qpfrcfajbnmmi3lzv3jrgdijvix5m1566rai5dizcm6kbpc";
    };
    vendorSha256 = "15m1br43hbp2ws2mnssgqvcna9z15l6yvy89jqhgz79p1l0bj4bx";
  };

  humanlog = self.buildGoModule rec {
    pname = "humanlog";
    version = "0.4.0";
    src = self.fetchFromGitHub {
      owner = "aybabtme";
      repo = "humanlog";
      rev = "${version}";
      sha256 = "1d5fs1sk61ksxbs5nyd3l4238jy2wxn0c3h8aamic5sy3mwr7gnv";
    };
    subPackages = [ "cmd/humanlog" ];
    vendorSha256 = null;
  };

  fly = self.buildGoModule rec {
    pname = "fly";
    version = "6.3.0";
    src = self.fetchFromGitHub {
      owner = "concourse";
      repo = "concourse";
      rev = "v${version}";
      sha256 = "006qkg661hzbc2gpcnpxm09bp1kbb98y0bgdr49bjlnapcmdgr1b";
    };
    vendorSha256 = "03az7l9rf2syw837zliny82xhkqlad16z0vfcg5h21m3bhz6v6jy";
    subPackages = [ "fly" ];
    buildFlagsArray = ''
      -ldflags=
        -X github.com/concourse/concourse.Version=${version}
    '';
  };
}
