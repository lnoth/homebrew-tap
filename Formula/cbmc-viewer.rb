class CbmcViewer < Formula
  include Language::Python::Virtualenv
  desc "Scans the output of CBMC and produces a browsable summary of the results"
  homepage "https://github.com/awslabs/aws-viewer-for-cbmc"
  url "https://github.com/awslabs/aws-viewer-for-cbmc.git",
      tag:      "viewer-3.0.1",
      revision: "8dc38024fa95528deddaf9726dbd394911a5d577"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/model-checking/cbmc-viewer/releases/download/viewer-3.0.1"
    sha256 cellar: :any_skip_relocation, big_sur:      "1c64d1454166f8bca681ee5d52a3daae2f2bfaa5054e505d304989089ce7e287"
    sha256 cellar: :any_skip_relocation, catalina:     "3602bf65cc1d7a65f8d0f46f2ffeab69b742b37e804148116a8daa2bebb9a079"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3992e7210f064406b1c6596c64a12b7fa8f5754b0efb3da53f3648cf3bd23cea"
  end

  depends_on "cbmc" => :test
  depends_on "python@3.9"
  depends_on "universal-ctags"

  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/91/a5/429efc6246119e1e3fbf562c00187d04e83e54619249eb732bb423efa6c6/Jinja2-3.0.3.tar.gz"
    sha256 "611bb273cd68f3b993fabdc4064fc858c5b47a973cb5aa7999ec1ba405c87cd7"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/bf/10/ff66fea6d1788c458663a84d88787bae15d45daa16f6b3ef33322a51fc7e/MarkupSafe-2.0.1.tar.gz"
    sha256 "594c67807fb16238b30c44bdf74f36c02cdf22d1c8cda91ef8a0ed8dabf5620a"
  end

  resource "voluptuous" do
    url "https://files.pythonhosted.org/packages/c0/2c/ccbeb25364e3e0c5e4522f13d66e2fc639bb4d4ecdf73be0959552cbecb4/voluptuous-0.12.2.tar.gz"
    sha256 "4db1ac5079db9249820d49c891cb4660a6f8cae350491210abce741fabf56513"
  end

  def install
    virtualenv_install_with_resources
    bash_completion.install "src/cbmc_viewer/etc/bash_completion.d/cbmc-viewer.sh"
  end

  test do
    (testpath/"main.c").write <<~EOS
      #include <stdlib.h>

      static int global;

      int main() {
        int *ptr = malloc(sizeof(int));
        assert(global > 0);
        return 0;
      }
    EOS

    system "goto-cc", "-o", "main.goto", "main.c"
    (testpath/"cbmc.xml").write shell_output("cbmc main.goto --trace --xml-ui", 10)
    (testpath/"coverage.xml").write shell_output("cbmc main.goto --cover location --xml-ui")
    (testpath/"property.xml").write shell_output("cbmc main.goto --show-properties --xml-ui")
    system bin/"cbmc-viewer", "--goto", "main.goto",
                              "--result", "cbmc.xml",
                              "--coverage", "coverage.xml",
                              "--property", "property.xml",
                              "--srcdir", "."
    assert_predicate testpath/"report/html/index.html", :exist?
  end
end
