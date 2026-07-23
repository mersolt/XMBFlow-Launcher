/*
 * XMBFlow native installer probe.
 *
 * This is deliberately not the launcher.  It exists only to isolate VPK
 * installation from the Lua Player Plus runtime: it performs no file I/O,
 * scanning, installation, launching, rebooting, or system configuration.
 */
#include <psp2/kernel/processmgr.h>
#include <psp2/kernel/threadmgr.h>

int main(void) {
    /* Stay alive briefly so a successful installation can be launch-checked. */
    sceKernelDelayThread(2000000);
    sceKernelExitProcess(0);
    return 0;
}
