
```
# For aarch64-windows stuff
 $ export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 

 $ nix-build -A x86_64.hello-uefi
 $ nix-build -A aarch64.hello-uefi
```


## `RC` workaround

In Nixpkgs:

```patch
diff --git a/pkgs/development/compilers/llvm/common/libunwind/default.nix b/pkgs/development/compilers/llvm/common/libunwind/default.nix
index 515914e6acb6..b57039e88bec 100644
--- a/pkgs/development/compilers/llvm/common/libunwind/default.nix
+++ b/pkgs/development/compilers/llvm/common/libunwind/default.nix
@@ -70,6 +70,9 @@ stdenv.mkDerivation (rec {
   cmakeFlags = lib.optional (lib.versionAtLeast release_version "15") "-DLLVM_ENABLE_RUNTIMES=libunwind"
     ++ lib.optional (!enableShared) "-DLIBUNWIND_ENABLE_SHARED=OFF";
 
+  # XXX only for `*-windows` targets; required for `aarch64-windows`...
+  RC = "${stdenv.cc.bintools.targetPrefix}windres";
+
   meta = llvm_meta // {
     # Details: https://github.com/llvm/llvm-project/blob/main/libunwind/docs/index.rst
     homepage = "https://clang.llvm.org/docs/Toolchain.html#unwind-library";
```

Does not make the build succeed anyways...

```
    Change Dir: '/build/libunwind-src-17.0.6/runtimes/build/CMakeFiles/CMakeScratch/TryCompile-OqbIpO'
    
    Run Build Command(s): /nix/store/hlxymn46n1xv6d0lq2jmcbl9b6g2l8s9-ninja-1.11.1/bin/ninja -v cmTC_43926
    [1/2] /nix/store/v8vb2112q5s2j9i4anr53p2vbd8119jy-aarch64-windows-clang-wrapper-17.0.6/bin/aarch64-windows-clang   -O0 -g -Xclang -gcodeview -D_DEBUG -D_DL
L -D_MT -Xclang --dependent-lib=msvcrtd -MD -MT CMakeFiles/cmTC_43926.dir/testCCompiler.c.obj -MF CMakeFiles/cmTC_43926.dir/testCCompiler.c.obj.d -o CMakeFiles
/cmTC_43926.dir/testCCompiler.c.obj -c /build/libunwind-src-17.0.6/runtimes/build/CMakeFiles/CMakeScratch/TryCompile-OqbIpO/testCCompiler.c
    [2/2] : && /nix/store/v8vb2112q5s2j9i4anr53p2vbd8119jy-aarch64-windows-clang-wrapper-17.0.6/bin/aarch64-windows-clang -nostartfiles -nostdlib -O0 -g -Xclan
g -gcodeview -D_DEBUG -D_DLL -D_MT -Xclang --dependent-lib=msvcrtd -Xlinker /subsystem:console  -fuse-ld=lld-link CMakeFiles/cmTC_43926.dir/testCCompiler.c.obj
 -o cmTC_43926.exe -Xlinker /MANIFEST:EMBED -Xlinker /implib:cmTC_43926.lib -Xlinker /pdb:cmTC_43926.pdb -Xlinker /version:0.0   -lkernel32 -luser32 -lgdi32 -l
winspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32 -loldnames  && :
    FAILED: cmTC_43926.exe 
    : && /nix/store/v8vb2112q5s2j9i4anr53p2vbd8119jy-aarch64-windows-clang-wrapper-17.0.6/bin/aarch64-windows-clang -nostartfiles -nostdlib -O0 -g -Xclang -gco
deview -D_DEBUG -D_DLL -D_MT -Xclang --dependent-lib=msvcrtd -Xlinker /subsystem:console  -fuse-ld=lld-link CMakeFiles/cmTC_43926.dir/testCCompiler.c.obj -o cm
TC_43926.exe -Xlinker /MANIFEST:EMBED -Xlinker /implib:cmTC_43926.lib -Xlinker /pdb:cmTC_43926.pdb -Xlinker /version:0.0   -lkernel32 -luser32 -lgdi32 -lwinspo
ol -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32 -loldnames  && :
    clang: warning: argument unused during compilation: '-rtlib=compiler-rt' [-Wunused-command-line-argument]
    aarch64-windows-lld-link: error: could not open 'kernel32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'user32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'gdi32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'winspool.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'shell32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'ole32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'oleaut32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'uuid.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'comdlg32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'advapi32.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'oldnames.lib': No such file or directory
    aarch64-windows-lld-link: error: could not open 'msvcrtd.lib': No such file or directory
    clang: error: linker command failed with exit code 1 (use -v to see invocation)
    ninja: build stopped: subcommand failed.
```
