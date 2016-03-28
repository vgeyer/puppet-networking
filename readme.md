# Networking Puppet Module

Manage (dualstack-)network interfaces.

## Usage

```puppet
class { 'networking':
    inet6_loopback => true,
    interfaces => {
      'test0' => {
        auto  => true,
        mac  => '00:25:90:f8:sc:ec',
        inet => {
          method => 'static',
          family_settings => {
            address        => '144.76.42.151',
            network        => '144.76.42.128',
            netmask        => '27',
            gateway        => '144.76.42.129'
          },
        },
        inet6 => {
          method => 'static',
          family_settings => {
            address     => '2a01:4f8:111:439a:0:0:0:1',
            netmask     => '96',
            gateway     => 'fe80::1'
          }
        }
      },
    }
}
```

Specifing inet6_loopback with true does result in a `iface lo inet6 loopback` line which is required for having the IPv6 applied to the interface. [Read more...](http://serverfault.com/questions/602700/debian-ipv6-is-not-asssigned-to-interface)

This module does install the `iftab` package on your system and so u should be able to rename your interfaces. If u want to do so, specifiy the MAC address. If u dont specify a MAC while giving non standard interface names like `eth0` ur network service wont start.

Specifing `inet` or `inet6` is optional.