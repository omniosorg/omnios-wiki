VirtualBox Notes
-----------------

**NOTE: AMD PCnet-PCI NICs not supported**

The “PCnet-PCI II” virtual adapter is not supported in the pcn driver.

“PCnet-PCI III” is known to have issues with DHCP and perhaps other
traffic.

For best results, use one of the Intel PRO/1000 adapters (e1000g
driver).

Note that if you want PXE boot support for Intel adapters you will also
need the Oracle VM VirtualBox Extension Pack from
<https://www.virtualbox.org/wiki/Downloads>
