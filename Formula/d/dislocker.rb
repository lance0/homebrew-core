class Dislocker < Formula
  desc "FUSE driver to read/write Windows' BitLocker-ed volumes"
  homepage "https://github.com/Aorimn/dislocker"
  url "https://github.com/Aorimn/dislocker/archive/refs/tags/v0.7.4.tar.gz"
  sha256 "c39261727a4993af13f90beec5ce1b56932f8a6d813df26e437ed0a668cf4141"
  license "GPL-2.0-or-later"

  bottle do
    rebuild 2
    sha256 cellar: :any, arm64_linux:  "6fc800d70967d83257c8716d1a802960c44a892f7a3594db882737cceebeb5c3"
    sha256 cellar: :any, x86_64_linux: "5656ee57b450b544d660941fa9682cc999dcde547cd4b3911f5f5660c82a4b71"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "libfuse"
  depends_on :linux # on macOS, requires closed-source macFUSE
  depends_on "openssl@4"

  # Backport support for OpenSSL
  patch :DATA # https://github.com/Aorimn/dislocker/commit/e749eade55f242d03fb9d10c05ff4b11c66dcbbe

  def install
    args = %w[
      -DCRYPTO_BACKEND=openssl
      -DWITH_RUBY=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"dislocker", "-h"
  end
end

__END__
diff --git a/include/dislocker/ssl_bindings.h.in b/include/dislocker/ssl_bindings.h
rename from include/dislocker/ssl_bindings.h.in
rename to include/dislocker/ssl_bindings.h
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index c578e35..7337db6 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -116,14 +116,8 @@ endif()
 # Libraries
 set (CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
 
-find_package (PolarSSL REQUIRED)
-if(POLARSSL_FOUND  AND  POLARSSL_INCLUDE_DIRS  AND  POLARSSL_LIBRARIES)
-	include_directories (${POLARSSL_INCLUDE_DIRS})
-	set (LIB ${LIB} ${POLARSSL_LIBRARIES})
-	configure_file (${PROJECT_SOURCE_DIR}/include/dislocker/ssl_bindings.h.in ${PROJECT_SOURCE_DIR}/include/dislocker/ssl_bindings.h ESCAPE_QUOTES @ONLY)
-else()
-	return ()
-endif()
+find_package (MbedTLS 3 REQUIRED)
+set (LIB ${LIB} MbedTLS::mbedcrypto)
 
 # Ruby bindings
 set(WITH_RUBY "AUTO" CACHE STRING "Enable Ruby bindings. Valid values are ON, OFF, or AUTO")
