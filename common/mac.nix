{ ... }: {
  # use a different mac address for each connection, but keep it per connection.
  # the mac is derived from a system private key, this allows to avoid a network
  # from identifying you are mac address spoofing while still preventing global
  # tracking through MAC address maps.
  networking.networkmanager.wifi.macAddress = "stable";
  networking.networkmanager.ethernet.macAddress = "stable";
}
