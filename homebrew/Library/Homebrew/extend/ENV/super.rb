require "extend/ENV/shared"
require "development_tools"

# ### Why `superenv`?
#
# 1. Only specify the environment we need (NO LDFLAGS for cmake)
# 2. Only apply compiler specific options when we are calling that compiler
# 3. Force all incpaths and libpaths into the cc instantiation (less bugs)
# 4. Cater toolchain usage to specific Xcode versions
# 5. Remove flags that we don't want or that will break builds
# 6. Simpler code
# 7. Simpler formula that *just work*
# 8. Build-system agnostic configuration of the tool-chain
module Superenv
  include SharedEnvExtension

  # @private
  attr_accessor :keg_only_deps, :deps

  attr_accessor :x11
  alias x11? x11

  def self.extended(base)
    base.keg_only_deps = []
    base.deps = []
  end

  # @private
  def self.bin
  end

  def reset
    super
    # Configure scripts generated by autoconf 2.61 or later export as_nl, which
    # we use as a heuristic for running under configure
    delete("as_nl")
  end

  # @private
  def setup_build_environment(formula = nil)
    super
    send(compiler)

    self["MAKEFLAGS"] ||= "-j#{determine_make_jobs}"
    self["PATH"] = determine_path
    self["PKG_CONFIG_PATH"] = determine_pkg_config_path
    self["PKG_CONFIG_LIBDIR"] = determine_pkg_config_libdir
    self["HOMEBREW_CCCFG"] = determine_cccfg
    self["HOMEBREW_OPTIMIZATION_LEVEL"] = "Os"
    self["HOMEBREW_BREW_FILE"] = HOMEBREW_BREW_FILE.to_s
    self["HOMEBREW_PREFIX"] = HOMEBREW_PREFIX.to_s
    self["HOMEBREW_CELLAR"] = HOMEBREW_CELLAR.to_s
    self["HOMEBREW_OPT"] = "#{HOMEBREW_PREFIX}/opt"
    self["HOMEBREW_TEMP"] = HOMEBREW_TEMP.to_s
    self["HOMEBREW_OPTFLAGS"] = determine_optflags
    self["HOMEBREW_ARCHFLAGS"] = ""
    self["CMAKE_PREFIX_PATH"] = determine_cmake_prefix_path
    self["CMAKE_FRAMEWORK_PATH"] = determine_cmake_frameworks_path
    self["CMAKE_INCLUDE_PATH"] = determine_cmake_include_path
    self["CMAKE_LIBRARY_PATH"] = determine_cmake_library_path
    self["ACLOCAL_PATH"] = determine_aclocal_path
    self["M4"] = DevelopmentTools.locate("m4") if deps.any? { |d| d.name == "autoconf" }
    self["HOMEBREW_ISYSTEM_PATHS"] = determine_isystem_paths
    self["HOMEBREW_INCLUDE_PATHS"] = determine_include_paths
    self["HOMEBREW_LIBRARY_PATHS"] = determine_library_paths
    self["HOMEBREW_DEPENDENCIES"] = determine_dependencies
    self["HOMEBREW_FORMULA_PREFIX"] = formula.prefix unless formula.nil?

    # The HOMEBREW_CCCFG ENV variable is used by the ENV/cc tool to control
    # compiler flag stripping. It consists of a string of characters which act
    # as flags. Some of these flags are mutually exclusive.
    #
    # O - Enables argument refurbishing. Only active under the
    #     make/bsdmake wrappers currently.
    # x - Enable C++11 mode.
    # g - Enable "-stdlib=libc++" for clang.
    # h - Enable "-stdlib=libstdc++" for clang.
    # K - Don't strip -arch <arch>, -m32, or -m64
    # w - Pass -no_weak_imports to the linker
    #
    # On 10.8 and newer, these flags will also be present:
    # s - apply fix for sed's Unicode support
    # a - apply fix for apr-1-config path
  end
  alias generic_setup_build_environment setup_build_environment

  private

  def cc=(val)
    self["HOMEBREW_CC"] = super
  end

  def cxx=(val)
    self["HOMEBREW_CXX"] = super
  end

  def determine_cxx
    determine_cc.to_s.gsub("gcc", "g++").gsub("clang", "clang++")
  end

  def homebrew_extra_paths
    []
  end

  def determine_path
    paths = [Superenv.bin]

    # Formula dependencies can override standard tools.
    paths += deps.map { |d| d.opt_bin.to_s }

    paths += homebrew_extra_paths
    paths += %w[/usr/bin /bin /usr/sbin /sbin]

    # Homebrew's apple-gcc42 will be outside the PATH in superenv,
    # so xcrun may not be able to find it
    case homebrew_cc
    when "gcc-4.2"
      begin
        apple_gcc42 = Formulary.factory("apple-gcc42")
      rescue FormulaUnavailableError
      end
      paths << apple_gcc42.opt_bin.to_s if apple_gcc42
    when GNU_GCC_REGEXP
      gcc_formula = gcc_version_formula($&)
      paths << gcc_formula.opt_bin.to_s
    end

    paths.to_path_s
  end

  def homebrew_extra_pkg_config_paths
    []
  end

  def determine_pkg_config_path
    paths  = deps.map { |d| "#{d.opt_lib}/pkgconfig" }
    paths += deps.map { |d| "#{d.opt_share}/pkgconfig" }
    paths.to_path_s
  end

  def determine_pkg_config_libdir
    paths = %w[/usr/lib/pkgconfig]
    paths += homebrew_extra_pkg_config_paths
    paths.to_path_s
  end

  def homebrew_extra_aclocal_paths
    []
  end

  def determine_aclocal_path
    paths = keg_only_deps.map { |d| "#{d.opt_share}/aclocal" }
    paths << "#{HOMEBREW_PREFIX}/share/aclocal"
    paths += homebrew_extra_aclocal_paths
    paths.to_path_s
  end

  def homebrew_extra_isystem_paths
    []
  end

  def determine_isystem_paths
    paths = ["#{HOMEBREW_PREFIX}/include"]
    paths += homebrew_extra_isystem_paths
    paths.to_path_s
  end

  def determine_include_paths
    keg_only_deps.map { |d| d.opt_include.to_s }.to_path_s
  end

  def homebrew_extra_library_paths
    []
  end

  def determine_library_paths
    paths = keg_only_deps.map { |d| d.opt_lib.to_s }
    paths << "#{HOMEBREW_PREFIX}/lib"
    paths += homebrew_extra_library_paths
    paths.to_path_s
  end

  def determine_dependencies
    deps.map(&:name).join(",")
  end

  def determine_cmake_prefix_path
    paths = keg_only_deps.map { |d| d.opt_prefix.to_s }
    paths << HOMEBREW_PREFIX.to_s
    paths.to_path_s
  end

  def homebrew_extra_cmake_include_paths
    []
  end

  def determine_cmake_include_path
    paths = []
    paths += homebrew_extra_cmake_include_paths
    paths.to_path_s
  end

  def homebrew_extra_cmake_library_paths
    []
  end

  def determine_cmake_library_path
    paths = []
    paths += homebrew_extra_cmake_library_paths
    paths.to_path_s
  end

  def homebrew_extra_cmake_frameworks_paths
    []
  end

  def determine_cmake_frameworks_path
    paths = deps.map { |d| d.opt_frameworks.to_s }
    paths += homebrew_extra_cmake_frameworks_paths
    paths.to_path_s
  end

  def determine_make_jobs
    if (j = self["HOMEBREW_MAKE_JOBS"].to_i) < 1
      Hardware::CPU.cores
    else
      j
    end
  end

  def determine_optflags
    if ARGV.build_bottle?
      arch = ARGV.bottle_arch || Hardware.oldest_cpu
      Hardware::CPU.optimization_flags.fetch(arch)
    elsif Hardware::CPU.intel? && !Hardware::CPU.sse4?
      Hardware::CPU.optimization_flags.fetch(Hardware.oldest_cpu)
    elsif compiler == :clang
      "-march=native"
    # This is mutated elsewhere, so return an empty string in this case
    else
      ""
    end
  end

  def determine_cccfg
    ""
  end

  public

  # Removes the MAKEFLAGS environment variable, causing make to use a single job.
  # This is useful for makefiles with race conditions.
  # When passed a block, MAKEFLAGS is removed only for the duration of the block and is restored after its completion.
  def deparallelize
    old = delete("MAKEFLAGS")
    if block_given?
      begin
        yield
      ensure
        self["MAKEFLAGS"] = old
      end
    end

    old
  end
  alias j1 deparallelize

  def make_jobs
    self["MAKEFLAGS"] =~ /-\w*j(\d+)/
    [$1.to_i, 1].max
  end

  def universal_binary
    check_for_compiler_universal_support

    self["HOMEBREW_ARCHFLAGS"] = Hardware::CPU.universal_archs.as_arch_flags

    # GCC doesn't accept "-march" for a 32-bit CPU with "-arch x86_64"
    return if compiler == :clang
    return unless Hardware::CPU.is_32_bit?
    self["HOMEBREW_OPTFLAGS"] = self["HOMEBREW_OPTFLAGS"].sub(
      /-march=\S*/,
      "-Xarch_#{Hardware::CPU.arch_32_bit} \\0"
    )
  end

  def permit_arch_flags
    append "HOMEBREW_CCCFG", "K"
  end

  def m32
    append "HOMEBREW_ARCHFLAGS", "-m32"
  end

  def m64
    append "HOMEBREW_ARCHFLAGS", "-m64"
  end

  def cxx11
    if homebrew_cc == "clang"
      append "HOMEBREW_CCCFG", "x", ""
      append "HOMEBREW_CCCFG", "g", ""
    elsif gcc_with_cxx11_support?(homebrew_cc)
      append "HOMEBREW_CCCFG", "x", ""
    else
      raise "The selected compiler doesn't support C++11: #{homebrew_cc}"
    end
  end

  def libcxx
    append "HOMEBREW_CCCFG", "g", "" if compiler == :clang
  end

  def libstdcxx
    append "HOMEBREW_CCCFG", "h", "" if compiler == :clang
  end

  # @private
  def refurbish_args
    append "HOMEBREW_CCCFG", "O", ""
  end

  %w[O3 O2 O1 O0 Os].each do |opt|
    define_method opt do
      self["HOMEBREW_OPTIMIZATION_LEVEL"] = opt
    end
  end

  def set_x11_env_if_installed
  end

  # @private
  def noop(*_args); end

  # These methods are no longer necessary under superenv, but are needed to
  # maintain an interface compatible with stdenv.
  alias fast noop
  alias O4 noop
  alias Og noop
  alias libxml2 noop
  alias set_cpu_flags noop

  # These methods provide functionality that has not yet been ported to
  # superenv.
  alias gcc_4_0_1 noop
  alias minimal_optimization noop
  alias no_optimization noop
  alias enable_warnings noop
end

class Array
  def to_path_s
    map(&:to_s).uniq.select { |s| File.directory? s }.join(File::PATH_SEPARATOR).chuzzle
  end
end

require "extend/os/extend/ENV/super"
