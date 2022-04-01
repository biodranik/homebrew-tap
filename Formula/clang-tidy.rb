class ClangTidy < Formula
  desc "Linting tools for C, C++ and Obj-C"
  homepage "https://clang.llvm.org/extra/clang-tidy/"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/llvm-project-14.0.0.src.tar.xz"
  sha256 "35ce9edbc8f774fe07c8f4acdf89ec8ac695c8016c165dd86b8d10e7cba07e23"
  # The LLVM Project is under the Apache License v2.0 with LLVM Exceptions
  license "Apache-2.0" => { with: "LLVM-exception" }
  version_scheme 1
  head "https://github.com/llvm/llvm-project.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/llvmorg[._-]v?(\d+(?:\.\d+)+)}i)
  end

  bottle do
    root_url "https://github.com/fmenezes/homebrew-tap/releases/download/clang-tidy-14.0.0"
    sha256 cellar: :any_skip_relocation, big_sur:      "3289b3b396c30d1fa61aee141e667596ffd93cabaae8d394f23c43046366d33c"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d580aecb3245079a9e497bbee99eaced2225346aefc248a5dfbbde4e28b86abc"
  end

  depends_on "cmake" => :build

  uses_from_macos "libxml2"
  uses_from_macos "ncurses"
  uses_from_macos "python", since: :catalina
  uses_from_macos "zlib"

  def install
    system "cmake", "-S", buildpath/"llvm", "-B", "build",
                    "-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra",
                    "-DLLVM_INCLUDE_BENCHMARKS=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build", "--target", "clang-tidy"

    bin.install "build/bin/clang-tidy"
  end

  test do
    ENV.prepend_path "PATH", bin
    (testpath/"test.c").write <<~EOS
      int         main(int argc, char **args) { \n   \t printf("hello"); }
    EOS
    assert_match(/implicitly declaring library function \'printf\' with type/, shell_output("clang-tidy #{testpath}/test.c 2>&1"))
    assert_match Regexp.new("#{version}".gsub(".", "\\.")), shell_output("clang-tidy --version")
  end
end
