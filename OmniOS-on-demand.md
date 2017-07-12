OmniOS on demand
================

OmniOS-on-demand is a cron(1)-driven script. It tracks changes in local
copies of both illumos-omnios and omnios-build. If there are changes
(“gate churn”) in either, the script will start a build after a certain
period of calm after the last gate churn event. It is available in
\$OMNIOS\_BUILD\_PATH/tools/.

OmniOS-on-demand starts parallel builds of illumos-omnios and
omnios-build. It uses the \[wiki:buildctl\#PREBUILT\_ILLUMOS
PREBUILT\_ILLUMOS\] environment variable to allow the parallel builds.
Because of the current default ordering of omnios-build's package list,
omnios-build will block for a while waiting for illumos-omnios to
finish.

On an 8-core single-processor 3.2GHz Xeon E5 system, a build of
OmniOS-on-demand takes slightly more than 5 hours. Improvements in this
script, or in \[wiki:buildctl\] itself should further reduce this time.

Deploying OmniOS on demand
--------------------------

### System requirements

A machine that can build illumos-omnios AND has enough swap in /tmp to
build any arbitrary package in omnios-build is all you need. Our
experience has shown that 16-32GB of memory, at least 4 processor cores,
and 100GB of disk space should be more than enough to make this work.
Due to illumos bug [5938](https://illumos.org/issues/5938), there must
be a swap device (e.g. a zvol) enabled, even a very small one, or else
at least the OpenJDK build will hang the build process until a swap
devices is added.

### User profile

A dedicated user (we use “builder”) can be assigned to run the
OmniOS-on-demand script in its cron(1) table, once per minute. Unless
gate churn is high, this script will perform no-change git pulls,
followed by a quick exit.

### sudoers entries

The user profile for OmniOS-on-demand requires a specific entry in
/etc/sudoers or /etc/sudoers.d. Basically, the Kayak build script should
be allowed to be run under sudo without user interaction. This allows
cron(1)-driven OmniOS-on-demand to run smoothly. An example line:

The \$OMNIOS\_BUILD\_PATH/tools/ directory also contains a sample file
for /etc/sudoers.d/.
