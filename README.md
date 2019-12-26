# VSSEasy
Easy way to work with Volume Shadow Copy (VSS)

For Correct work use Windows Vista or newer

This tool is for command line use only. The script use native Windows WMI to interact with volume shadow copy.

How to Use
----------------

VSSEasy [option] [parameters]

OPTIONS:

CreateShadowCopy:      Create an shadow copy.
DeleteShadowCopyByID:  Delete an shadow copy.
MountShadowCopy:       Mounts a shadow copy as a directory where the content is the disk root of the snapshot.
UnmountShadowCopy:     Unmount an shadow copy.

EXAMPLES:

VSSEasy CreateShadowCopy C:\some\directory

VSSEasy DeleteShadowCopyByID {00000000-0000-0000-0000-000000000000}

VSSEasy MountShadowCopy {00000000-0000-0000-0000-000000000000} C:\some\directory\to\mount

VSSEasy UnmountShadowCopy C:\chosed\directory\to\mount
