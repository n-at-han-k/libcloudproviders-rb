{
  fiddle = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vifygrkw22gcd4wzh8gc4pv6h1zpk6kll6mmprrf5174wvfxa3z";
      type = "gem";
    };
    version = "1.1.8";
  };
  gio2 = {
    dependencies = ["fiddle" "gobject-introspection"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g5nsicd09vd323mpjdg3q8c7cavq00c0wi8j6bfywxmvr7dxzxv";
      type = "gem";
    };
    version = "4.4.0";
  };
  glib2 = {
    dependencies = ["native-package-installer" "pkg-config"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yxjj9ab71yhn7syzfbsk74vzzb1xbchpb0yl9dpcz856c21raqc";
      type = "gem";
    };
    version = "4.4.0";
  };
  gobject-introspection = {
    dependencies = ["glib2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "032jh10zpwfbzvfpc6mgc7nfw2a7nn84sww1g3c0ma25v4fyhky9";
      type = "gem";
    };
    version = "4.4.0";
  };
  native-package-installer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bvr9q7qwbmg9jfg85r1i5l7d0yxlgp0l2jg62j921vm49mipd7v";
      type = "gem";
    };
    version = "1.1.9";
  };
  pkg-config = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "079fz8vkjrjjmid3k5a6bwp9vssvv3hxm4c8v5121vlmfs65517y";
      type = "gem";
    };
    version = "1.6.6";
  };
}
