Building illumos (illumos-gate or illumos-omnios) on OmniOS
===========================================================

Starting with \[wiki:ReleaseNotes/r151016 r151016\], building
[illumos-gate](https://github.com/illumos/illumos-gate) or our own
downstream
[illumos-omnios](https://github.com/omniti-labs/illumos-omnios) is more
straightforward.

`1. Have a machine or VM with a minimum of 8GB of RAM, and 10GB of free disk space.`

`2. [wiki:Installation Install] r151016 or later of OmniOS, boot it, and [wiki:GeneralAdministration configure it] per instruction on this wiki.`

`3. Install the single metapackage ``.  `` contains compilers, closed binaries, and other tools required to build illumos-gate.  With privilege or as root:`\
`  `

`4. Clone the repo of your choice using git, and perform any modifications.  `*`'NOTE:`` ``For`` ``OmniOS,`` ``if`` ``you`` ``want`` ``to`` ``use`` ``the`` ``precise`` ``source`` ``of`` ``a`` ``given`` ``release,`` ``check`` ``out`` ``that`` ``branch`` ``(e.g.`` ``branch`` `**`r151016`**` ``for`` ``r151016).`` ``The`` ``master`` ``branch`` ``of`` ``OmniOS`` ``corresponds`` ``roughly`` ``to`` ``bloody`` ``(master`` ``may`` ``be`` ``ahead`` ``a`` ``few`` ``commits`` ``of`` ``available`` ``bloody`` ``releases).`*`'`\
`  `

`5. You may wish to use techniques `[`here`](https://kebesays.blogspot.com/2011/03/for-illumos-newbies-on-developing-small.html)` to verify your changes prior to building the entire illumos repo.`

`6. Copy /opt/onbld/env/omnios-illumos-gate or .../omnios-illumos-omnios depending on which illumos repo you're building, and modify the GATE and CODEMGR_WS variables to match your repo.  You can also modify the NIGHTLY_OPTIONS to reduce or increase the amount that is built.  The default is to build DEBUG & packages, plus lint.  Call it $HOME/build/my.env for this example.`\
`  `

`7. Run nightly.  Nightly will compile even uncommitted changes, so make sure your source reflects what you want compiled.`\
`  `

`8. A mail should arrive to $LOGNAME@localhost.  You can also check mail_msg or nightly.log in $CODEMGR_WS/log/log-`<date>`/.`\
`  `

`9. Use the onu(1ONBLD) tool to create a new boot environment using your freshly-compiled illumos bits.  If you build both DEBUG and non-DEBUG, you can choose which bits.  Use beadm(1M) to make sure the BE you want is selected for your next reboot.`\
`  `

[Image(Screen Shot 2015-10-29 at 1.08.59
PM.png)](Image(Screen_Shot_2015-10-29_at_1.08.59_PM.png) "wikilink")
